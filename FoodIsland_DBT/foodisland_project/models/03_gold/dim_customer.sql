select
        customer_id,
        customer_name,
        email as customer_email,
        age,
        case
            when age < 18 then 'Under 18'
            when age between 18 and 24 then '18-24'
            when age between 25 and 34 then '25-34'
            when age between 35 and 44 then '35-44'
            when age between 45 and 54 then '45-54'
            when age between 55 and 64 then '55-64'
            when age is null then 'Unknown'
            else '65+'
        end as age_group,
        gender,
        marital_status,
        occupation,
        income_band,
        education_level,
        family_size

from {{ ref('foodisland_silv_users') }}