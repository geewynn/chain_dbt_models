{{ config(
     materialized='incremental',
     unique_key='block_number',
     incremental_strategy='delete+insert'
) }}

{% set SONIC_LAUNCH = '2024-12-18' %}

WITH 
source AS (SELECT * FROM {{ ref('stg_transactions') }}),

src AS (
    /* one scan, one GROUP BY — no correlated sub-query needed */
    SELECT
        block_number,
        min(block_timestamp)                     AS block_ts,
        toDate(min(block_timestamp))             AS block_date,
        count()                                  AS tx_per_block
    FROM source
    WHERE toDate(block_timestamp) >= toDate('{{ SONIC_LAUNCH }}')
    {% if is_incremental() %}
        AND block_number > (SELECT max(block_number) FROM {{ this }})
    {% endif %}
    GROUP BY block_number
)

SELECT
    block_number,
    block_date,
    block_ts,
    tx_per_block
FROM src