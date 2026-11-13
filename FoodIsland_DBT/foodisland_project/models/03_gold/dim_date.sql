{{ config(materialized='table') }}

with date_spine as (

    {{ dbt_utils.date_spine(
        datepart="day",                             
        start_date="cast('2015-01-01' as date)",   
        end_date="cast(date_add(current_date(), 1) as date)"
    ) }}

)

select
    ds.date as date_day,
    year(ds.date) as year,
    month(ds.date) as month,
    dayofmonth(ds.date) as day,
    quarter(ds.date) as quarter,
    date_format(ds.date, 'yyyy-MM-dd') as date_str
from date_spine ds
order by ds.date;