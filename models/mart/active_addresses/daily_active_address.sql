{{
    config(
        materialized='view'
         )
}}

with source as (
    select * from {{ ref('int_active_addresses') }}
),

final as (
    select
        block_date,
        COUNT(distinct `address`) as active_address,
        COUNT(distinct IF(is_new_user = 1, `address`, null)) as new_address,
        COUNT(distinct IF(is_new_user = 0, `address`, null)) as returning_address
    from source
    group by block_date
)

select
    block_date,
    active_address,
    new_address,
    returning_address
from final
