{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='order_item_id'
) }}

select 
    order_item_id,
    order_id, r_id as restaurant_id,
    f_id,
    cast(price as decimal(10,2)) as price, 
    cast(quantity as decimal(10,2)) as quantity,
    cast(line_amount as decimal(10,2)) as line_amount,
    _ingestion_date

from {{ source('bronze_layer', 'foodisland_order_items_incremental') }}
where try_cast(order_item_id as bigint) is not null

{% if is_incremental() %}
    and _ingestion_date > (select max(_ingestion_date) from {{ this }})
{% endif %}