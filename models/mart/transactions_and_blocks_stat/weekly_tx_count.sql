{{ config(materialized='view') }}

with source as (
    select * from {{ ref('int_block_tx_counts') }}
),

final as (
    select
        date_trunc('week', block_date) as week_start,
        SUM(tx_per_block) as tx_count
    from source
    group by week_start
)

select
    week_start,
    tx_count
from final
