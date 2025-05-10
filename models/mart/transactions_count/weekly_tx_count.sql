-- models/marts/fct_tx_daily.sql
{{ config(materialized='view') }}

with source as (
    select * from {{ ref('int_block_tx_counts') }}
)

SELECT
    date_trunc('week', block_date)   AS week_start,
    SUM(tx_per_block)                AS tx_count
FROM source
GROUP BY week_start
