-- models/marts/fct_tx_daily.sql
{{ config(materialized='view') }}

with source as (
    select * from {{ ref('int_block_tx_counts') }}
)

select
    date_trunc('month', block_date) as month_start,
    SUM(tx_per_block) as tx_count
from source
group by month_start
