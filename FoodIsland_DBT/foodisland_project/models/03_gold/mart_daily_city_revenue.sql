select 
    order_date, 
    city, 
    
    -- Nombre total de commandes passées (tous statuts confondus)
    count(*) as orders, 
    
    -- Nombre de commandes qui ont été livrées avec succès
    count_if(is_delivered) as delivered_orders,
    
    -- Taux d'annulation (nombre de commandes annulées / nombre total de commandes), arrondi à 4 décimales
    -- Utilisation de div0 pour éviter les erreurs de division par zéro
    round(div0(count_if(order_status = 'Cancelled'), count(*)), 4) as cancel_rate,
    
    -- Volume Brut de Marchandises (GMV) : Chiffre d'affaires total généré uniquement par les commandes livrées
    sum(iff(is_delivered, sales_amount, 0)) as gmv,
    
    -- Panier Moyen (AOV - Average Order Value) : GMV divisé par le nombre de commandes livrées, arrondi à 2 décimales
    round(div0(sum(iff(is_delivered, sales_amount, 0)), count_if(is_delivered)), 2) as aov

from {{ ref('fact_orders') }} 

-- Regroupement des résultats par date de commande (1) et par ville (2)
group by 1, 2;