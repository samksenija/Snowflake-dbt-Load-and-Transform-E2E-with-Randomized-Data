# Snowflake-dbt-Load-and-Transform-E2E-with-Randomized-Data
Snowflake x dbt E2E LT project with randomized data
<br/>
<br/>
Storing the data in centralised environment; Data extraction from PDFs using Cortex AI; Data transformations;
<br/>
<br/>
This project uses datasets & PDFs generated from these repositories:
<br/>
https://github.com/samksenija/Randomized-Datasets-in-Snowflake-1.0 (Create randomized dummy ledger data)
<br/>
https://github.com/samksenija/Create-My-Own-Dummy-PDFs (Create dummy PDFs using dummy ledger data)
<br/>
<br/>
Helpful documentation: https://www.snowflake.com/en/developers/guides/create-a-document-processing-pipeline-with-ai-extract/
## Process
### Load & Extract
The process consists of storing all data sources in centralised environment. Once data sources are stored in dedicated internal stage, needed data is extracted data from unstructured sources (PDFs in this case, sample of PDF can be found in `LT` folder). To extract data Snowflake's `AI_EXTRACT` is used, which is feature that allows to trough set of questions extract needed data. This is  example how `AI_EXTRACT` was used in my code:
```
SELECT AI_EXTRACT(
      file => TO_FILE(stage_name, file_path),
      responseFormat => [
        ['credit', 'What is the credit value?'], 
        ['debit', 'What is the debit value?'],
        ['account_description', 'What is the account description?'],
        ['date', 'What is the date of the transaction?'],
        ['reference', 'What is the reference?']]
    );
```
`AI_EXTRACT` returns data, in this case, in JSON format.
<br/>
<br/>
In some sense, this is a take on ELT, and extraction of data does happen in a sense, however, only after unstructured data sources have been loaded in desired environment.
<br/>
<br/>
In order to extract data continuously, whenever new files have been added to the stage, streams and tasks have been utilized. Stream will 'capture' that new files have been added to the stage (`INSERT`) and will trigger a task. Tasks 'job' is to extract file metadata, as well as data provided by the `AI_EXTRACT`. In order to utilize furhter extracted information, task will save data in a previously created table. However, job here is not done. As `AI_EXTRACT` returns data, in this case, in JSON format, a view is created on the table that will 'help' present JSON data in table format. 
<br/>
```
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
```
## Steps for Load & Extract
1. Create internal stage
2. Create function that will apply `AI_EXTRACT` on files stored in the stage, given that the structure of files and what data needs to be extracted is known
3. Create stream on the stage
4. Create table where file metadata and `AI_EXTRACT` initial result will be stored
5. Create task that will run on stream change capture (`INSERT` into stage in this case) and poulate table created in previous step
6. Create a view that will 'show' extracted data from `AI_EXTRACT` JSON
