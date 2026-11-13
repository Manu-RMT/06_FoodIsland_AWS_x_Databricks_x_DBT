select
    food_id,
    food_name,
    food_type
from {{ ref('foodisland_silv_foods') }}