# Project Overview

The NYC Payroll Data Warehouse project delivers a robust solution for processing, analyzing, and storing payroll data for New York City. Leveraging Azure Data Factory, the project orchestrates Extract, Transform, and Load (ETL) workflows to convert raw data from various sources into a well-structured data warehouse hosted on Azure SQL Database. This system facilitates advanced analytics and reporting, empowering data-driven decision-making in employee compensation, agency performance, and workforce management.
This project is designed to support NYC's goals in two key areas:
Financial Resource Allocation Analysis: Provide insights into how the City allocates its financial resources, focusing on determining what portion of the budget is allocated to overtime expenses.
Transparency and Public Accessibility: Make payroll data publicly accessible to promote transparency and demonstrate how municipal employees spend the City's budget on salaries and overtime pay.
By addressing these objectives, the NYC Payroll Data Warehouse contributes to more effective financial oversight and fosters public trust through data-driven transparency.

##Introduction

Led an end-to-end data engineering project processing New York City's payroll data using Azure cloud services. Leveraged Azure Data Factory for ETL workflows and Azure Data Studio for data transformation, enabling efficient analysis of municipal employee compensation patterns. The solution automated data ingestion and processing, providing a scalable framework for payroll data management.

#Objecties

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


##Architecture


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

##Dataset 

https://github.com/oluwatoyin-ibitoye/adf_nycpayroll/blob/main/AgencyMaster.csv
https://github.com/oluwatoyin-ibitoye/adf_nycpayroll/blob/main/EmpMaster.csv
https://github.com/oluwatoyin-ibitoye/adf_nycpayroll/blob/main/TitleMaster.csv
https://github.com/oluwatoyin-ibitoye/adf_nycpayroll/blob/main/nycpayroll_2020.xlsx
https://github.com/oluwatoyin-ibitoye/adf_nycpayroll/blob/main/nycpayroll_2021.csv

## Data Warehouse Design
The NYC payroll data warehouse is designed using a **star schema** for efficient querying and analysis.

# Data Model
![ER DIAGRAM.drawio](https://github.com/oluwatoyin-ibitoye/adf_nycpayroll/blob/main/ER%20DIAGRAM.drawio)



##Setup and Configuration

Prerequisites

1.Azure subscription with contributor access
3.Git installed
4.Azure Data Studio installed
##script for Project
##Learning Learn
##Conclusion

