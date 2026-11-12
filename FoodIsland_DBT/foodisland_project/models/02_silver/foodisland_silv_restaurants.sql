{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='restaurant_id'
) }}

-- Modèle de nettoyage et standardisation des restaurants Food Island

select

    -- Identifiant unique du restaurant converti en numérique
    cast(id as bigint) as restaurant_id,

    -- Nom du restaurant
    name as restaurant_name,

    -- Extraction de la ville :
    -- si le champ contient plusieurs valeurs séparées par des virgules,
    -- on récupère la dernière partie puis on supprime les espaces inutiles
    trim(
        coalesce(
            regexp_extract(city, '([^,]+)$', 1),
            city
        )
    ) as city,

    -- Note du restaurant :
    -- conversion en décimal (3 chiffres dont 1 décimale)
    -- les valeurs '--' sont considérées comme NULL
    try_cast(
        nullif(rating, '--')
        as decimal(3,1)
    ) as rating,

    -- Nombre d'avis :
    -- extraction de la partie numérique du texte puis conversion en nombre
    try_cast(
        regexp_extract(rating_count, '[0-9]+', 0)
        as bigint
    ) as rating_count,

    -- Coût moyen pour deux personnes :
    -- extraction du montant numérique puis conversion en nombre
    try_cast(
        regexp_extract(cost, '[0-9]+', 0)
        as bigint
    ) as cost_for_two,

    -- Type(s) de cuisine proposé(s)
    cuisine,

    -- Numéro de licence du restaurant
    lic_no as license_number

from {{ source('bronze_layer', 'foodisland_restaurant_incremental') }}

-- Conservation uniquement des lignes dont l'identifiant est numérique
where try_cast(id as bigint) is not null