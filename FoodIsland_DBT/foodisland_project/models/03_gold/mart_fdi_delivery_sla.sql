select 
    city, 
    -- Extraction de l'heure à laquelle la commande a été passée (de 0 à 23)
    hour(order_timestamp) as order_hour, 
    
    -- Nombre total de commandes livrées (simplifié de count_if puisque le WHERE filtre déjà)
    count(*) as delivered_orders,
    
    -- Médiane (P50) du temps de livraison en minutes, arrondie à 1 décimale
    round(median(delivery_time_min), 1) as p50_delivery_min, 
    
    -- 90e percentile (P90) du temps de livraison en minutes, arrondi à 1 décimale
    -- (90% des commandes sont livrées en moins de ce temps)
    round(percentile_cont(0.9) within group (order by delivery_time_min), 1) as p90_delivery_min

from {{ ref('fact_fdi_orders') }} 

-- Filtrer uniquement sur les commandes qui ont été effectivement livrées
where is_delivered 

-- Regroupement des résultats par ville (1) et par heure de commande (2)
group by 1, 2;