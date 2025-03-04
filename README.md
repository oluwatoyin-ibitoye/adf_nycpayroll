
# Project Overview

The NYC Payroll Data Warehouse project delivers a robust solution for processing, analyzing, and storing payroll data for New York City. Leveraging Azure Data Factory, the project orchestrates Extract, Transform, and Load (ETL) workflows to convert raw data from various sources into a well-structured data warehouse hosted on Azure SQL Database. This system facilitates advanced analytics and reporting, empowering data-driven decision-making in employee compensation, agency performance, and workforce management.
This project is designed to support NYC's goals in two key areas:
Financial Resource Allocation Analysis: Provide insights into how the City allocates its financial resources, focusing on determining what portion of the budget is allocated to overtime expenses.
Transparency and Public Accessibility: Make payroll data publicly accessible to promote transparency and demonstrate how municipal employees spend the City's budget on salaries and overtime pay.
By addressing these objectives, the NYC Payroll Data Warehouse contributes to more effective financial oversight and fosters public trust through data-driven transparency.

## Introduction

I Led an end-to-end data engineering project processing New York City's payroll data using Azure cloud services. Leveraged Azure Data Factory for ETL workflows and Azure Data Studio for data transformation, enabling efficient analysis of municipal employee compensation patterns. The solution automated data ingestion and processing, providing a scalable framework for payroll data management.

# Objecties

• Design a Data Warehouse for NYC

• Develop a scalable and automated ETL Pipeline to load the payroll data NYC data
warehouse

• Develop aggregate table(s) in the Data warehouse for easy analysis of the key business
questions

• Ensure quality and consistency of data in your pipeline

• Create a public user with limited privileges to enable public access to the NYC Data
warehouse

• Properly document all your processes for reproducibility – version control

• Maintain a cloud-hosted repository of your codebase to facilitate collaboration with team members


## Architecture


![project Architecture](https://github.com/oluwatoyin-ibitoye/adf_nycpayroll/blob/main/NYCpayroll_pipeline_architecture.drawio.png)


### Data Flow
1. **Source Systems**: NYC payroll data (CSV/Excel files)
2. **Azure Data Factory**: Orchestrates the ETL pipeline.
3. **Azure Data Lake Storage**: Stores raw and processed data.
4. **Azure SQL Database**: Hosts the data warehouse.

## Technologies Used
- **Azure Data Factory**: ETL orchestration.
- **Azure Data Studio**: SQL development and database management.
- **Azure Data Lake Storage**: Data storage.
- **Azure SQL Database**: Data warehouse.
- **GitHub**: Version control and collaboration.

## Benefits of choice technology
- **Data Integrity**: Ensures preservation of raw data for auditing and debugging.
- **Scalability**: Supports large datasets with efficient storage and querying.
- **Flexibility**: Accommodates schema changes and new data sources with minimal disruption.


## Dataset 

https://github.com/oluwatoyin-ibitoye/adf_nycpayroll/blob/main/AgencyMaster.csv
https://github.com/oluwatoyin-ibitoye/adf_nycpayroll/blob/main/EmpMaster.csv
https://github.com/oluwatoyin-ibitoye/adf_nycpayroll/blob/main/TitleMaster.csv
https://github.com/oluwatoyin-ibitoye/adf_nycpayroll/blob/main/nycpayroll_2020.xlsx
https://github.com/oluwatoyin-ibitoye/adf_nycpayroll/blob/main/nycpayroll_2021.csv

## Data Warehouse Design
The NYC payroll data warehouse is designed using a **star schema** for efficient querying and analysis.

# Data Model

![ER DIAGRAM.drawio](https://github.com/oluwatoyin-ibitoye/adf_nycpayroll/blob/main/ER_DIAGRAM.png)



## Setup and Configuration

Prerequisites
1.Azure subscription with contributor access
2. Integrated services
3.Git installed
4.Azure Data Studio installed

# setup instructions

1. Clone this repository:
   "`bash
   git clone 
GitHub Repository; https://github.com/oluwatoyin-ibitoye/adf_nycpayroll/blob/main/README.md
   ```
2. Deploy Azure services using ARM templates.
3. Configure secrets in Azure Key Vault.
4. Deploy database objects via Azure Data Studio.
5. Deploy Azure Data Factory pipelines using copy/Get metadata, ForLoop activies
6. Execute the initial data load.


## script for Project
![An end to end pipeline completed](https://github.com/oluwatoyin-ibitoye/adf_nycpayroll/blob/main/Screenshot%202025-01-14%20234728.png)

A copy to stage activity from my container in jason format

(https://github.com/oluwatoyin-ibitoye/adf_nycpayroll/blob/main/nyc_pipeline_copy1.json).

Stored procedure to populate the data warehouse 

(https://github.com/oluwatoyin-ibitoye/adf_nycpayroll/blob/main/stored_procedure.sql)

Public Access Permission 

(https://github.com/oluwatoyin-ibitoye/adf_nycpayroll/blob/main/public_Access_permission.sql)




## Methodology
 NYC Payroll Data Warehouse Schemas
# 1. Staging Schema (STG)
The Staging Schema (STG) is the initial landing zone for raw data extracted from the source. I designed it to host unprocessed data in its original format, ensuring that the integrity of the source data is maintained. This schema served as a temporary storage area before the data was transformed and loaded into the data warehouse (EDW).

 Key Features of STG:
- **Raw Data Storage**: Stores data precisely as extracted from the source systems (CSV).
- **Temporary Tables**: This schema's data is transient and typically purged after successful transformation and loading.
- **Error Handling**: Captures any issues during the extraction process for debugging and resolution.
Example Tables in STG:
1. `STG.nycpayroll_2020`
2. `STG.nycpayroll_2021`

2. Loading Schema (EDW)
The Loading Schema (EDW) is the core of the data warehouse, hosting transformed and structured data optimized for analytics and reporting. The schema hosted, cleaned/Transformed, validated, and Data enriched to support business intelligence use cases.

Key Features of EDW:
- **Transformed Data**: Hosts data that has undergone cleaning, validation, and enrichment.
- **Dimension and Fact Tables**: Organized into star or snowflake schema for efficient querying.
- **Historical Data**: Maintains historical records to support trend analysis and reporting.

1.	**Extraction**:
Preprocessing:
Data is sourced from an on-premises system, with files stored locally.
•	The extraction of data is performed using the integration runtime of Azure Data Factory, which allows for secure communication between on-premises systems and Azure.
Once extracted, the data is temporarily stored in a hierarchical structure within Azure Blob Storage (data lake), ensuring it remains in a file format instead of being stored as blocks. This location serves as a staging area, with the data saved in CSV format. A resource group and Azure storage account were established on Azure to support the creation of a container for the dataset, making it accessible for the orchestration of the pipeline.
EXTRACTION:
A new pipeline was developed in Azure Data Factory (ADF) to facilitate the extraction process. The pipeline leverages the Copy activity to transfer files from the data lake. Additionally, the Get Metadata activity is used to retrieve all files from a specified Blob Storage folder, ensuring an efficient and time-saving process.
EXTRACTION:
A new pipeline was developed in Azure Data Factory (ADF) to facilitate the extraction process. The pipeline leverages the Copy activity to transfer files from the data lake. Additionally, the Get Metadata activity was used to retrieve all files from the Blob Storage folder, ensuring an efficient and time-saving process. A connection was established by using creating source and sink
Benefits of Get Metadata 
•	Facilitates dynamic and efficient pipeline designs.
•	Enhances flexibility for file and folder processing workflows.
•	Reduces manual intervention by automating decision-making based on metadata.
ForEach was linked to the Get Metadata to create a copy activity which iterate over a collection of files present to execute copy to staging area in the pipeline. It is a looping construct that enabled me to perform repetitive tasks on a dynamic or predefined list of inputs. 
Benefits ForEach :
•	Automates repetitive tasks.
•	Improves flexibility and scalability by handling dynamic collections.
•	Allows both sequential and parallel processing to balance efficiency and resource utilization.

Staging Schema (STG) in Azure Data Factory
The Staging Schema (STG) serves as the foundational layer of the data pipeline and acts as the initial landing zone for raw data extracted from source systems. Designed with Azure Data Factory (ADF), this schema ensures the integrity of the source data by storing it in its original, unprocessed format. It acts as a temporary repository where data is staged before undergoing transformations and being loaded into the Data Warehouse           
Staging Schema Architecture in Azure Data Factory
Core Design Principles
1. **Data Integrity Preservation**
   - Captures source data exactly as extracted
   - Minimal initial processing
   - Supports comprehensive auditing

2. **Flexible Data Ingestion**
   - Handles multiple data sources
   - Supports incremental and full data loads
   - Accommodates varying source data structures
Key Components
1. Raw Data Staging Table
   - Mirrors source data schema
   - Comprehensive metadata tracking
   - Built-in validation flags
   - Detailed error capturing mechanism
2. Error Logging System
   - Captures extraction and validation errors
   - Provides detailed error diagnostics
   - Supports troubleshooting and data quality management
3. Load Tracking Mechanism
   - Monitors ETL process metadata
   - Tracks processing metrics
   - Enables performance analysis
Azure Data Factory Workflow
1. Data Extraction
   - Used Get Metadata/Copy Activity to extract data in CSV format
   - Supports multiple source systems
2. Data Validation
   - Automated quality checks
   - Identifies problematic records
   - Provides granular validation feedback
3. Error Handling
   - Comprehensive error logging
   - Prevents pipeline interruption
   - Supports manual intervention and debugging
Advantages
- Ensures source data integrity
- Provides a clear separation between extraction and transformation
- Facilitates robust error management
- Supports comprehensive data lineage tracking
2. Transformation:
Azure Data Studio played a crucial role in designing the data warehouse schema, creating a robust structure optimized for storage, querying, and reporting. The schema architecture focused on three primary components:
1. Fact Table
   The fact table serves as the central repository for the nycpayroll data, capturing measurable metrics and establishing critical relationships through foreign key connections to dimension tables. This design allows for complex analytical queries and multi-dimensional reporting.
2. Dimension Tables
   Dimension tables provide rich contextual information, enabling sophisticated data filtering, grouping, and categorization. These tables include detailed attributes about:
   - Temporal characteristics (date and time dimensions)
   - Employee demographics
   - Job titles and classifications
3. Error Log Table
   A dedicated error logging mechanism was implemented to capture and document any issues encountered during the Extract, Transform, Load (ETL) process. This table facilitates:
   - Comprehensive error tracking
   - Detailed debugging
   - Performance monitoring and quality assurance
Transformation Techniques
The data transformation phase focused on several key strategies to ensure data quality, consistency, and analytical readiness:

# Date Standardization
   - Converted ‘AgencyStartDate’ column to a uniform `YYYY-MM-DD` format
   - Ensured consistent date representation across all data sources
   - Simplified date-based calculations and comparisons
# Column Naming Conventions
   - Renamed AgencyID and AgencyCode to follow a clear, consistent naming schema
   - Improved code readability
   - Enhanced understanding of data elements
   - Created intuitive column names that reflect their content and purpose
# Concatenating data
   - Concatenated nycpayroll_2020 and nycpayroll_2021 for robust dataset
   - Merged relevant attributes to provide more comprehensive information
# Advanced Transformation Approaches
Beyond basic transformations, the process incorporated:
- Data type normalization
- Handling of null and missing values
- Removal of duplicate records
- Validation of data integrity
- Standardization of categorical values
# Outcome
The comprehensive transformation process resulted in:
- A clean, well-structured data warehouse
- Consistent and reliable data
- Optimized schema for advanced analytics
- Improved data quality and usability
By meticulously preparing and transforming the data, the project established a solid foundation for robust reporting and in-depth organizational insights.


## 3. Loading:
Loading Schema (EDW) in Azure Data Factory and Azure Data Studio
The Loading Schema (EDW) serves as the core of the data warehouse, hosting well-structured, transformed, and enriched data optimized for analytics and reporting. It provides a clean and organized repository designed to support business intelligence use cases by enabling efficient querying and insightful analysis.
Azure Data Factory (ADF) was utilized to orchestrate the ETL/ELT pipelines, while Azure Data Studio was employed to write and execute advanced SQL queries for data transformation, validation, and enrichment. Together, these tools ensured a robust and automated data processing workflow.
Workflow for Loading Schema (EDW):
# 1.	Data Transformation and Cleaning:
-	Data from the staging schema (STG) was cleaned and standardized in the loading process.
-	Operations such as null value handling, duplicate removal, and data type conversions ensured high-quality data.
# 2.	Schema Creation:
-	In Azure Data Studio, the schema for the EDW was designed to organize data into fact tables and dimension tables, following a star schema or snowflake schema architecture.
-	Fact tables contained transactional data, while dimension tables provided descriptive attributes for slicing and dicing.
# 3.	Stored Procedures:
-	Custom stored procedures were developed in Azure Data Studio to populate and manage the EDW. These procedures automated repetitive tasks, such as: 
-	Inserting and updating data: Data was loaded and refreshed incrementally or in bulk.
-	Aggregation: Metrics were pre-calculated for faster querying (e.g., totals, averages, counts).
-	Partitioning: Large tables were divided into manageable chunks for improved performance.
-	Indexing: Indices were applied to optimize query execution and retrieval speed.
-	Error Logging: Any issues or anomalies during the loading process were captured for debugging and resolution.
# 4.	Procedure Execution and Validation:
-	Stored procedures were executed in Azure Data Studio for testing and validation.
-	Debugging was conducted to ensure that the data transformations adhered to business rules and requirements.
-	Once validated, the procedures were configured to run as part of the ADF pipeline.
5.	Automation with Azure Data Factory:
-	ADF pipelines were set up to automate the execution of stored procedures, ensuring seamless data integration and continuous updates to the EDW.
-	Triggers were employed for scheduled or event-driven execution of the pipeline.
# Key Features of the Loading Schema (EDW):
1.	Transformed Data:
-	The EDW schema hosts clean, validated, and enriched data that supports various analytical use cases.
-	Ensures the data is ready for direct use by reporting tools like Power BI or Tableau.
2.	Dimension and Fact Tables:
-	Fact Tables: Contain measurable, transactional data, such as sales, payroll, or financial metrics.
-	Dimension Tables: Provide descriptive attributes (e.g., time, location, employee details) for querying and filtering.
-	Schema design adheres to best practices for efficient querying and analytics.
3.	Optimized for Performance:
-	Partitioning and indexing improve query performance and scalability for large datasets.
4.	Error Logging:
-	Logs issues encountered during the ETL/ELT process, enabling quick troubleshooting and resolution.

# Advantages of the Loading Schema (EDW):
•	Efficient Analytics: Transformed data is structured for high-performance querying and analysis.
•	Scalability: Supports large datasets and complex queries with features like partitioning and indexing.
•	Automation: Integration with ADF pipelines ensures minimal manual intervention and timely data updates.
•	Data Integrity: Validation and enrichment ensure the accuracy and reliability of data for business intelligence.
By combining the power of Azure Data Factory for orchestration and Azure Data Studio for SQL development, the Loading Schema (EDW) becomes the backbone of the data pipeline, enabling data-driven decision-making and comprehensive reporting.


## Public Access
•  A read-only user was created with limited privileges to allow public access to the data warehouse.

## Challenges and Solutions

1 Data Quality
•  Issue: Missing values in critical columns.
•  Solution: Implemented data cleaning steps in the ETL pipeline.
•  Issue: Date column in improper date format.
•  Solution: Implemented date standardization within Azure Data Factory's data flow to convert all date formats into a unified structure (e.g., YYYY-MM-DD)

2 Schema Alignment
•  Issue: Column name differences between 2020 and 2021 datasets.
•  Solution: Renamed columns in the 2020 dataset to match the 2021 dataset.

3 version contol
•  Issue: Struggled with connecting Azure Data Factory to GitHub for version control, leading to challenges in collaboration and pipeline management.
•  Solution: Consulted Microsoft's official documentation to properly configure the GitHub repository in Azure Data Factory.
Utilized a personal access token for authentication and granted necessary permissions for the repository.
Enabled branch policies to ensure code quality and organized workflow management.

4 Error Handling and Logging
 • Issue: Lack of proper error handling caused failures to go unnoticed, delaying issue resolution.
 • Solution: Implemented an ErrorLog table in the database to capture detailed information about ETL failures, including error number, severity, and message.
Added notifications and alerts in Azure Data Factory to inform the team of failures in real time.

## Lessons Learned
Standardizing schemas across datasets at the beginning of the project prevents downstream issues.
Proactive performance optimization (e.g., indexing and partitioning) is crucial for handling large datasets.
Effective error handling and real-time monitoring ensure timely resolution of issues.
Securely managing sensitive data with encryption and access controls is vital for compliance and trust.

## Project Outcomes

•  A fully functional data warehouse was created on Azure.
•  The ETL pipeline successfully loaded data into the data warehouse.
•  Data quality checks ensured consistency and accuracy.
•  Public access was enabled with a read-only user.

## Future Work
•  Automate the ETL pipeline using Azure Data Factory.
•  Add more datasets to the data warehouse.
•  Implement advanced analytics and reporting.
    Implement machine learning models for predictive analytics on payroll data.
    Automate the incremental data load pipeline using event triggers.


## Conclusion
This project demonstrates the end-to-end process of designing a data warehouse, developing an ETL pipeline, and loading data into a cloud-hosted database. The documented process ensures reproducibility and provides a foundation for future enhancements.

