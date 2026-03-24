with

transactions_with_accountant_data as (

    select * from {{ ref('int_join_transactions_with_user_data') }}

),

transactions_created_by_accountants as (

    select
        SUM(credit) as total_credit,
        SUM(debit) as total_debit,
        first_name,
        last_name,
        email
    from transactions_with_accountant_data

    group by first_name, last_name, email

)

select * from transactions_created_by_accountants
