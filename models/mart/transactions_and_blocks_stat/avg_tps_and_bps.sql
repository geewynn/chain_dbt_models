{{ config(materialized='view') }}

with source as (
    select * from {{ ref('int_block_tx_counts') }}
)

select
    count() as total_blocks,
    sum(tx_per_block) as total_tx,
    (max(block_ts) - min(block_ts)) as period_seconds,
    round(total_blocks / period_seconds, 2) as avg_bps,
    round(total_tx / period_seconds, 2) as avg_tps
from source
