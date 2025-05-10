{{ config(
     materialized='incremental',
     unique_key='block_number',
     incremental_strategy='delete+insert'
) }}

{% set SONIC_LAUNCH = '2024-12-18' %}

with
source as (select * from {{ ref('stg_transactions') }}),

src as (
    /* one scan, one GROUP BY — no correlated sub-query needed */
    select
        block_number,
        min(block_timestamp) as block_ts,
        toDate(min(block_timestamp)) as block_date,
        count() as tx_per_block
    from source
    where
        toDate(block_timestamp) >= toDate('{{ SONIC_LAUNCH }}')
        {% if is_incremental() %}
            and block_number > (select max(block_number) from {{ this }})
        {% endif %}
    group by block_number
)

select
    block_number,
    block_date,
    block_ts,
    tx_per_block
from src
