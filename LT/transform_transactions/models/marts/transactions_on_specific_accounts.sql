with

transactions as (

    select * from {{ ref('stg_transactions__pdf_transaction_view') }}

),

transactions_per_accounts as (

    select
        account_description,
        SUM(credit) as total_credit,
        SUM(debit) as total_debit
    from transactions

    group by account_description

)

select * from transactions_per_accounts
