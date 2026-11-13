select 
    order_date, 
    city, 
    
    -- Nombre total de commandes
    count(*) as orders, 
    
    -- Nombre de commandes livrées
    count_if(is_delivered) as delivered_orders,
    
    -- Taux d'annulation (nombre de commandes annulées / nombre total de commandes)
    round(coalesce(count_if(order_status = 'Cancelled') / nullif(count(*), 0), 0), 4) as cancel_rate,
    
    -- Volume Brut de Marchandises (GMV) : Chiffre d'affaires total généré uniquement par les commandes livrées
    sum(if(is_delivered, sales_amount, 0)) as gmv,
    
    -- Panier Moyen (AOV - Average Order Value) : GMV divisé par le nombre de commandes livrées, arrondi à 2 décimales
    round(coalesce(sum(if(is_delivered, sales_amount, 0)) / nullif(count_if(is_delivered), 0), 0), 2) as aov

from {{ ref('fact_fdi_orders') }} 

group by 1, 2;