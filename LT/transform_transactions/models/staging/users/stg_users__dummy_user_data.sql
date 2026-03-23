with

source as (

    select * from {{ source('randomized_user','dummy_user_data') }}

),

randomized_users as (

    select
        "user_id" as user_id,
        "first_name" as first_name,
        "last_name" as last_name,
        "email" as email
    from source

)

select * from randomized_users