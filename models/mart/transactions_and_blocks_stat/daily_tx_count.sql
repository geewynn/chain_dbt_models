{{ config(materialized='view') }}

with source as (
    select * from {{ ref('int_block_tx_counts') }}
),

final as (
    select
        block_date as day,
        SUM(tx_per_block) as tx_count
    from source
    group by day
)

select
    day,
    tx_count
from final
