{{ config(materialized='view') }}

with source as (
    select * from {{ ref('int_block_tx_counts') }}
),

final as (
    select
        block_ts as second,
        count() as blocks,
        sum(tx_per_block) as transaction_count,
        blocks as blocks_per_sec,
        transaction_count as transactions_per_sec
    from source
    group by block_ts
    order by transactions_per_sec desc
)

select
    second,
    blocks,
    transaction_count,
    blocks_per_sec,
    transactions_per_sec
from final
