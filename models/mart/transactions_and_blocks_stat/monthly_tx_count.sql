{{ config(materialized='view') }}

with source as (
    select * from {{ ref('int_block_tx_counts') }}
),

final as (
    select
        date_trunc('month', block_date) as month_start,
        SUM(tx_per_block) as tx_count
    from source
    group by month_start
)

select
    month_start,
    tx_count
from final
