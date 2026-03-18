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

--Wrapper function to extract data from documents
CREATE OR REPLACE FUNCTION extract_document_data(
    stage_name STRING,
    file_path STRING
)
RETURNS VARIANT
LANGUAGE SQL
AS $$
    SELECT AI_EXTRACT(
      file => TO_FILE(stage_name, file_path),
      responseFormat => [
        ['credit', 'What is the credit value?'], 
        ['debit', 'What is the debit value?'],
        ['account_description', 'What is the account description?'],
        ['date', 'What is the date of the transaction?'],
        ['reference', 'What is the reference?']]
    ):response
$$;

--Test function on the available PDF files in stage
SELECT
    RELATIVE_PATH,
    extract_document_data('@my_pdf_stage', RELATIVE_PATH) as EXTRACTED_DATA
FROM DIRECTORY('@my_pdf_stage');

--Create stream to track changes on stage
CREATE STREAM my_pdf_stream ON STAGE my_pdf_stage;
ALTER STAGE my_pdf_stage REFRESH;

--Create table to store initialy extracted data and file metadata
CREATE OR REPLACE TABLE pdf_dummy_data (
  file_name VARCHAR,
  file_size VARIANT,
  last_modified VARCHAR,
  json_content VARIANT
);

--Create task to process new files in stage and insert data into pdf_dummy_data table
CREATE OR REPLACE TASK load_new_file_data
  WAREHOUSE = COMPUTE_WH
  SCHEDULE = '1 minutes'
  COMMENT = 'Process new files in the stage and insert data into the pdf_dummy_data table.'
WHEN SYSTEM$STREAM_HAS_DATA('MY_PDF_STREAM')
AS
INSERT INTO pdf_dummy_data (
  SELECT
    RELATIVE_PATH AS file_name,
    size AS file_size,
    last_modified,
    extract_document_data('@my_pdf_stage', RELATIVE_PATH) AS json_content
  FROM my_pdf_stream
  WHERE METADATA$ACTION = 'INSERT'
);

ALTER TASK load_new_file_data RESUME;

--Create view to easily query the extracted data
CREATE VIEW pdf_reviews_view AS
SELECT 
    file_name,
    file_size,
    last_modified,
    json_content:"account_description"::STRING AS "account_description",
    json_content:"debit"::FLOAT AS "debit",
    json_content:"credit"::FLOAT AS "credit",
    json_content:"reference"::STRING AS "reference",
    json_content:"date"::DATETIME AS "date",
FROM pdf_dummy_data;







