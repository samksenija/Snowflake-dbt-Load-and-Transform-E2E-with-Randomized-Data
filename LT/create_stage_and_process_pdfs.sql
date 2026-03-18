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

--Testing out AI extract
SELECT AI_EXTRACT(
  file => TO_FILE('@my_pdf_stage','transaction_REF169.pdf'),
  responseFormat => [
    ['credit', 'What is the credit value?'], 
    ['debit', 'What is the debit value?'],
    ['account_description', 'What is the account description?'],
    ['date', 'What is the date of the transaction?'],
    ['reference', 'What is the reference?']]
);

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
