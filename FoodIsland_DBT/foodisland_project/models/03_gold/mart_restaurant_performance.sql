select 
    f.restaurant_id, 
    r.restaurant_name, 
    r.city, 
    r.cuisine, 
    -- Nombre total de commandes passées pour chaque restaurant
    count(*) as orders, 
    -- Chiffre d'affaires total généré (somme des montants uniquement pour les commandes livrées)
    sum(iff(f.is_delivered, f.sales_amount, 0)) as revenue, 
    -- Note moyenne des clients, arrondie à 2 décimales
    round(avg(f.customer_rating), 2) as avg_customer_rating, 
    -- Temps de livraison moyen en minutes, arrondi à 1 décimale
    round(avg(f.delivery_time_min), 1) as avg_delivery_min 
from {{ ref('fact_orders') }} f 
-- Jointure avec la dimension des restaurants pour récupérer leurs informations (nom, ville, type de cuisine)
left join {{ ref('dim_restaurants') }} r 
    using (restaurant_id) 
-- Regroupement des résultats par les 4 premières colonnes (restaurant_id, restaurant_name, city, cuisine)
group by 1, 2, 3, 4;