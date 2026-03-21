with

source as (

    select * from {{ source('randomized_transactions','pdf_transactions_view') }}

),

transactions as (

    select
        "account_description" as account_description,
        "credit" as credit,
        "debit" as debit,
        "reference" as reference,
        "date" as transaction_date,
        "accountant_id" as accountant_id
    from source

)

select * from transactions