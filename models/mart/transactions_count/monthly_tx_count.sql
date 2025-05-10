-- models/marts/fct_tx_daily.sql
{{ config(materialized='view') }}

with source as (
    select * from {{ ref('int_block_tx_counts') }}
)

SELECT
    date_trunc('month', block_date)  AS month_start,
    SUM(tx_per_block)                AS tx_count
FROM source
GROUP BY month_start