
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='review_id'
) }}


select
r.review_id,
r.order_id,
cast(r.user_id as bigint) as customer_id,
cast(r.restaurant_id as string) as restaurant_id,
cast(r.rating as bigint) as rating,
cast(r.comment as string) as comment,
cast(r.review_date as DATE) as review_date,
res.city as city,
r._ingestion_date

from {{ source('bronze_layer', 'foodisland_reviews_incremental') }} r
left join {{ ref('foodisland_silv_restaurants') }} res on r.restaurant_id = res.restaurant_id
where r.comment is not null


{% if is_incremental() %}
    and r._ingestion_date > (select max(_ingestion_date) from {{ this }})
{% endif %}