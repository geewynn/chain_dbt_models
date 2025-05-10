-- models/marts/fct_tx_daily.sql
{{ config(materialized='view') }}

with source as (
    select * from {{ ref('int_block_tx_counts') }}
)

SELECT
    block_date                 AS day,
    SUM(tx_per_block)          AS tx_count
FROM source
GROUP BY day
