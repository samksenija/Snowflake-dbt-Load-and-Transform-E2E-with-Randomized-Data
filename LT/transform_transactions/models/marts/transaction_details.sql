with

transactions as (

    select * from {{ ref('stg_transactions__pdf_transaction_view') }}

),

accountants as (

    select * from {{ ref('stg_users__dummy_user_data')}}

),

transaction_and_accountants_joined as (

    select
        transactions.account_description,
        transactions.credit,
        transactions.debit,
        transactions.reference,
        transactions.transaction_date,
        accountants.first_name,
        accountants.last_name,
        accountants.email
    from transactions

    left join accountants on transactions.accountant_id = accountants.user_id

)

select * from customers_and_customer_orders_joined