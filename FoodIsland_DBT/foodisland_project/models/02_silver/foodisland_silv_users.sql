{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='customer_id'
) }}

select 
    cast(user_id as bigint) as customer_id,
    name as customer_name,
    lower(email) as customer_email,
    try_cast(age as int) as age,
    gender,
    marital_status,
    Occupation as occupation,
    monthly_income as income_band,
    Educational_Qualifications as education_level,
    try_cast(family_size as int) as family_size

from {{ source('bronze_layer', 'foodisland_users_incremental') }}
where try_cast(user_id as bigint) is not null
