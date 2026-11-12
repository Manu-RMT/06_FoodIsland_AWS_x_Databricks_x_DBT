select 
    f_id as food_id,
    item as food_name,
    initicap(veg_or_non_veg) as food_type
from {{ source('bronze_layer', 'foodisland_food_incremental') }}
where try_cast(f_id as bigint) is not null
