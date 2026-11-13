 {{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='order_id'
) }} 

select 
    order_id, 
    order_timestamp,
    order_date,
    user_id as customer_id, 
    r_id as restaurant_id,
    trim(coalesce(nullif(regexp_extract(restaurant_city, '([^,]+)$', 1), ''),restaurant_city)) as city,
    cuisine, 
    items_count, 
    sales_qty, 
    subtotal, 
    discount, 
    delivery_fee, 
    gst, 
    sales_amount,
    currency, 
    payment_method, 
    order_status, 
    (order_status='Delivered') as is_delivered,
    customer_rating,
    delivery_time_min,
    _ingestion_date

from {{ source('bronze_layer', 'foodisland_orders_incremental') }}
where try_cast(order_id as bigint) is not null

{% if is_incremental() %}
    and _ingestion_date > (select max(_ingestion_date) from {{ this }})
{% endif %}