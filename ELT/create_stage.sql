--Create database & schema
--Use database & schema
CREATE DATABASE IF NOT EXISTS dummy_datasets;
USE DATABASE dummy_datasets;
CREATE SCHEMA IF NOT EXISTS schema_for_dummy_data;
USE SCHEMA schema_for_dummy_data;

--Create my_pdf_stage
CREATE STAGE IF NOT EXISTS my_pdf_stage
ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
DIRECTORY = (ENABLE = TRUE)
COMMENT = 'Stage for storing and processing PDF documents';

--Show upload result
LIST @my_pdf_stage;