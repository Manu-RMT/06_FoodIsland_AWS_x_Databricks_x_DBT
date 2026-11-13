{{ config(materialized='table') }}

with date_spine as (

    {{ dbt_utils.date_spine(
        datepart="day",                             
        start_date="cast('2015-01-01' as date)",   
        end_date="cast(date_add(current_date(), 1) as date)"
    ) }}

)

select
    ds.date_day, -- Corrigé de ds.date en ds.date_day
    year(ds.date_day) as year,
    month(ds.date_day) as month,
    dayofmonth(ds.date_day) as day,
    quarter(ds.date_day) as quarter,
    date_format(ds.date_day, 'yyyy-MM-dd') as date_str
from date_spine ds
order by ds.date_day;