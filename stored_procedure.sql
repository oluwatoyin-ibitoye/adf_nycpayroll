CREATE OR ALTER PROCEDURE [STG].[prc_nycpayroll]  
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Ensure the ErrorLog table exists for logging errors
        IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[EDW].[ErrorLog]') AND type = 'U')
        BEGIN
            CREATE TABLE [EDW].[ErrorLog](
                [ErrorID] INT IDENTITY(1,1) PRIMARY KEY,
                [ErrorNumber] INT NULL,
                [ErrorSeverity] INT NULL,
                [ErrorState] INT NULL,
                [ErrorProcedure] NVARCHAR(128) NULL,
                [ErrorLine] INT NULL,
                [ErrorMessage] NVARCHAR(4000) NULL,
                [ErrorDateTime] DATETIME DEFAULT GETDATE()
            );
        END;

        -- Load data into dimension and fact tables
        INSERT INTO [EDW].[dim_agency] (AgencyID, AgencyName)
        SELECT DISTINCT 
            AgencyID,
            AgencyName
        FROM [STG].[AgencyMaster] AS source
        WHERE NOT EXISTS (
            SELECT 1 
            FROM [EDW].[dim_agency] AS target
            WHERE target.AgencyID = source.AgencyID
        );

        INSERT INTO [EDW].[dim_employee] (EmployeeID, LastName, FirstName)
        SELECT DISTINCT
            EmployeeID,
            LastName,
            FirstName
        FROM [STG].[EmpMaster] AS source
        WHERE NOT EXISTS (
            SELECT 1 
            FROM [EDW].[dim_employee] AS target
            WHERE target.EmployeeID = source.EmployeeID
        );

        INSERT INTO [EDW].[dim_Title] (TitleCode, TitleDescription)
        SELECT DISTINCT 
            TitleCode, 
            TitleDescription
        FROM [STG].[TitleMaster] AS source
        WHERE NOT EXISTS (
            SELECT 1 
            FROM [EDW].[dim_Title] AS target
            WHERE target.TitleCode = source.TitleCode
        );

        -- Ensure TitleCode is added only once to fact_payroll
        IF COL_LENGTH('EDW.fact_payroll', 'TitleCode') IS NULL
        BEGIN
            ALTER TABLE EDW.fact_payroll
            ADD TitleCode NVARCHAR(50); -- Add TitleCode if missing
        END;

        -- Insert into fact_payroll with TitleCode handled properly
        INSERT INTO [EDW].[fact_payroll] (
    PayBasis,
    FiscalYear,
    PayrollNumber,
    AgencyID,
    EmployeeID,
    TitleCode,
    BaseSalary,
    RegularHours,
    RegularGrossPaid,
    OTHours,
    TotalOTPaid,
    TotalOtherPay,
    AgencyStartDate,
    WorkLocationBorough,
    LeaveStatusasofJune30
)
SELECT 
    p.PayBasis,
    p.FiscalYear,
    p.PayrollNumber,
    p.AgencyID,
    p.EmployeeID,
    p.TitleCode,
    CASE 
        WHEN ISNUMERIC(p.BaseSalary) = 1 THEN CAST(p.BaseSalary AS DECIMAL(18,2))
        ELSE NULL
    END AS BaseSalary,
    CASE 
        WHEN ISNUMERIC(p.RegularHours) = 1 THEN CAST(p.RegularHours AS DECIMAL(18,2))
        ELSE NULL
    END AS RegularHours,
    CASE 
        WHEN ISNUMERIC(p.RegularGrossPaid) = 1 THEN CAST(p.RegularGrossPaid AS DECIMAL(18,2))
        ELSE NULL
    END AS RegularGrossPaid,
    CASE 
        WHEN ISNUMERIC(p.OTHours) = 1 THEN CAST(p.OTHours AS DECIMAL(18,2))
        ELSE NULL
    END AS OTHours,
    CASE 
        WHEN ISNUMERIC(p.TotalOTPaid) = 1 THEN CAST(p.TotalOTPaid AS DECIMAL(18,2))
        ELSE NULL
    END AS TotalOTPaid,
    CASE 
        WHEN ISNUMERIC(p.TotalOtherPay) = 1 THEN CAST(p.TotalOtherPay AS DECIMAL(18,2))
        ELSE NULL
    END AS TotalOtherPay,
    CAST(p.AgencyStartDate AS DATE) AS AgencyStartDate,
    p.WorkLocationBorough,
    p.LeaveStatusasofJune30
FROM (
    SELECT * FROM [STG].[nycpayroll_2020]
    UNION ALL
    SELECT * FROM [STG].[nycpayroll_2021]
) p
WHERE NOT EXISTS (
    SELECT 1
    FROM [EDW].[fact_payroll] target
    WHERE target.EmployeeID = p.EmployeeID
      AND target.FiscalYear = p.FiscalYear
      AND target.PayrollNumber = p.PayrollNumber
);



        -- Create Borough Compensation Summary
        IF OBJECT_ID('EDW.agg_borough_compensation', 'U') IS NOT NULL
            DROP TABLE EDW.agg_borough_compensation;

        SELECT 
            WorkLocationBorough,
            FiscalYear,
            COUNT(DISTINCT EmployeeID) AS EmployeeCount,
            SUM(RegularGrossPaid) AS TotalRegularPay,
            SUM(TotalOTPaid) AS TotalOvertimePay,
            SUM(TotalOtherPay) AS TotalOtherPay,
            SUM(RegularGrossPaid + TotalOTPaid + TotalOtherPay) AS TotalCompensation,
            AVG(BaseSalary) AS AvgBaseSalary,
            MAX(BaseSalary) AS MaxBaseSalary,
            MIN(BaseSalary) AS MinBaseSalary
        INTO EDW.agg_borough_compensation
        FROM EDW.fact_payroll
        GROUP BY WorkLocationBorough, FiscalYear;

        -- Create Agency Compensation Summary
        IF OBJECT_ID('EDW.agg_agency_compensation', 'U') IS NOT NULL
            DROP TABLE EDW.agg_agency_compensation;

        SELECT 
            AgencyID,
            FiscalYear,
            COUNT(DISTINCT EmployeeID) AS EmployeeCount,
            SUM(RegularGrossPaid) AS TotalRegularPay,
            SUM(TotalOTPaid) AS TotalOvertimePay,
            SUM(TotalOtherPay) AS TotalOtherPay,
            SUM(RegularGrossPaid + TotalOTPaid + TotalOtherPay) AS TotalCompensation,
            AVG(BaseSalary) AS AvgBaseSalary,
            MAX(BaseSalary) AS MaxBaseSalary,
            MIN(BaseSalary) AS MinBaseSalary
        INTO EDW.agg_agency_compensation
        FROM EDW.fact_payroll
        GROUP BY AgencyID, FiscalYear;

        -- Create Year-over-Year Growth Analysis
        IF OBJECT_ID('EDW.agg_yearly_growth', 'U') IS NOT NULL
            DROP TABLE EDW.agg_yearly_growth;

        WITH YearlyStats AS (
            SELECT 
                FiscalYear,
                COUNT(DISTINCT EmployeeID) AS TotalEmployees,
                SUM(RegularGrossPaid + TotalOTPaid + TotalOtherPay) AS TotalCompensation
            FROM EDW.fact_payroll
            GROUP BY FiscalYear
        )
        SELECT 
            curr.FiscalYear,
            curr.TotalEmployees,
            curr.TotalCompensation,
            ((curr.TotalCompensation - prev.TotalCompensation) / NULLIF(prev.TotalCompensation, 0) * 100) AS YoY_Compensation_Change,
            ((curr.TotalEmployees - prev.TotalEmployees) / NULLIF(prev.TotalEmployees, 0) * 100) AS YoY_Employee_Change
        INTO EDW.agg_yearly_growth
        FROM YearlyStats curr
        LEFT JOIN YearlyStats prev ON curr.FiscalYear = prev.FiscalYear + 1;

        -- Create Pay Basis Analysis
        IF OBJECT_ID('EDW.agg_pay_basis', 'U') IS NOT NULL
            DROP TABLE EDW.agg_pay_basis;

        SELECT 
            PayBasis,
            FiscalYear,
            COUNT(DISTINCT EmployeeID) AS EmployeeCount,
            SUM(RegularGrossPaid + TotalOTPaid + TotalOtherPay) AS TotalCompensation,
            AVG(BaseSalary) AS AvgBaseSalary,
            MAX(BaseSalary) AS MaxBaseSalary,
            MIN(BaseSalary) AS MinBaseSalary
        INTO EDW.agg_pay_basis
        FROM EDW.fact_payroll
        GROUP BY PayBasis, FiscalYear;

-- Create Title Analysis
IF OBJECT_ID('EDW.agg_title_analysis', 'U') IS NOT NULL
    DROP TABLE EDW.agg_title_analysis;

SELECT 
    p.TitleCode, -- Use TitleCode directly from fact_payroll
    t.TitleDescription, -- Fetch TitleDescription from TitleMaster or dim_Title
    p.FiscalYear,
    COUNT(DISTINCT p.EmployeeID) AS EmployeeCount,
    SUM(p.RegularGrossPaid) AS TotalRegularPay,
    SUM(p.TotalOTPaid) AS TotalOvertimePay,
    AVG(p.BaseSalary) AS AvgBaseSalary,
    MAX(p.BaseSalary) AS MaxBaseSalary,
    MIN(p.BaseSalary) AS MinBaseSalary
INTO EDW.agg_title_analysis
FROM EDW.fact_payroll p
LEFT JOIN [STG].[TitleMaster] t ON p.TitleCode = t.TitleCode -- Join with TitleMaster
GROUP BY p.TitleCode, t.TitleDescription, p.FiscalYear;

-- Create Overtime Analysis Summary
IF OBJECT_ID('EDW.agg_overtime_analysis', 'U') IS NOT NULL
            DROP TABLE EDW.agg_overtime_analysis;

        SELECT 
            AgencyID,
            FiscalYear,
            COUNT(DISTINCT EmployeeID) AS EmployeeCount,
            SUM(OTHours) AS TotalOTHours,
            SUM(TotalOTPaid) AS TotalOTPaid,
            AVG(OTHours) AS AvgOTHours,
            MAX(OTHours) AS MaxOTHours,
            MIN(OTHours) AS MinOTHours,
            SUM(TotalOTPaid) / NULLIF(SUM(RegularGrossPaid), 0) * 100 AS OvertimeToRegularPayRatio
        INTO EDW.agg_overtime_analysis
        FROM EDW.fact_payroll
        WHERE OTHours > 0
        GROUP BY AgencyID, FiscalYear;

        -- Log successful execution
        INSERT INTO [EDW].[ErrorLog] (
            ErrorNumber,
            ErrorMessage,
            ErrorDateTime
        )
        VALUES (
            0,
            'Successfully processed payroll and created aggregates.',
            GETDATE()
        );

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        INSERT INTO [EDW].[ErrorLog] (
            ErrorNumber,
            ErrorSeverity,
            ErrorState,
            ErrorProcedure,
            ErrorLine,
            ErrorMessage,
            ErrorDateTime
        )
        VALUES (
            ERROR_NUMBER(),
            ERROR_SEVERITY(),
            ERROR_STATE(),
            ERROR_PROCEDURE(),
            ERROR_LINE(),
            ERROR_MESSAGE(),
            GETDATE()
        );

        THROW;
    END CATCH;
END;


