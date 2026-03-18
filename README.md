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
<br/>
<br/>
## Process
### Create Internal Stage
Create internal stage in order to load PDF files into it. 
### Create UDF which Utilises AI_EXTRACT
AI_EXTRACT (https://docs.snowflake.com/en/sql-reference/functions/ai_extract) is Snowflake's feature that could be utilised to extract data from unstructured sources such as PDFs.
<br/>

