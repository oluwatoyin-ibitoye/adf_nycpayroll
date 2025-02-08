-- Correcting the SQL procedure to use dynamic SQL for CREATE USER and ALTER USER

CREATE OR ALTER PROCEDURE security.CreatePublicUser
    @Password nvarchar(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Generate password if not provided
        IF @Password IS NULL
            SET @Password = CONVERT(nvarchar(100), NEWID()) + 'Aa1!';

        -- Create or update the PublicUser account using dynamic SQL
        IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'PublicUser')
        BEGIN
            DECLARE @CreateUserSQL nvarchar(max);
            SET @CreateUserSQL = 'CREATE USER [PublicUser] WITH PASSWORD = ''' + @Password + '''';
            EXEC sp_executesql @CreateUserSQL;
        END
        ELSE
        BEGIN
            DECLARE @AlterUserSQL nvarchar(max);
            SET @AlterUserSQL = 'ALTER USER [PublicUser] WITH PASSWORD = ''' + @Password + '''';
            EXEC sp_executesql @AlterUserSQL;
        END

        -- Grant permissions
        GRANT SELECT ON security.vw_public_employee_data TO PublicUser;
        GRANT SELECT ON security.vw_public_salary_stats TO PublicUser;
        DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::payroll TO PublicUser;
        GRANT CONNECT TO PublicUser;

        -- Log the event
        INSERT INTO security.SecurityAuditLog (EventType, EventDescription, Username)
        VALUES (
            'User ' + CASE 
                WHEN EXISTS (SELECT * FROM sys.database_principals WHERE name = 'PublicUser') 
                THEN 'Update' 
                ELSE 'Creation' 
            END,
            'PublicUser permissions ' + CASE 
                WHEN EXISTS (SELECT * FROM sys.database_principals WHERE name = 'PublicUser') 
                THEN 'refreshed' 
                ELSE 'created' 
            END,
            SYSTEM_USER
        );

        -- Return the generated password
        SELECT @Password AS GeneratedPassword;
    END TRY
    BEGIN CATCH
        -- Proper THROW syntax
        DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity int = ERROR_SEVERITY();
        DECLARE @ErrorState int = ERROR_STATE();

        INSERT INTO security.SecurityAuditLog (EventType, EventDescription, Username)
        VALUES ('Error', @ErrorMessage, SYSTEM_USER);

        THROW @ErrorSeverity, @ErrorMessage, @ErrorState;
    END CATCH
END;

