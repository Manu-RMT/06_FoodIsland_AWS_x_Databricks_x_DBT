select
    menu_id as menu_id,
    try_cast(r_id as bigint) as restaurant_id,
    f_id as food_id,
    cuisine,
    try_cast(price as decimal(10,2)) as price

from {{ source('bronze_layer', 'foodisland_menu_incremental') }}
where try_cast(r_id as bigint) is not null

