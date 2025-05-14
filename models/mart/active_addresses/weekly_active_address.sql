{{ config(
     materialized = 'view' 
) }}

with source as (
    select * from {{ ref('int_active_addresses') }}
),

final as (
    select
        date_trunc('week', block_date) as week_start,
        COUNT(distinct `address`) as active_address,
        COUNT(distinct IF(is_new_user = 1, `address`, null)) as new_address,
        COUNT(distinct IF(is_new_user = 0, `address`, null)) as returning_address
    from source
    group by week_start
)

select
    week_start,
    active_address,
    new_address,
    returning_address
from final
