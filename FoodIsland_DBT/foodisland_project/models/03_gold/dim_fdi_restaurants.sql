select 
    restaurant_id,
    restaurant_name,
    city,
    cuisine,
    rating,
    rating_count,
    cost_for_two
from {{ ref('foodisland_silv_restaurants') }}
