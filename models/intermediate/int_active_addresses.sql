{{ 
    config(
     materialized='incremental',
     unique_key=['block_date', 'address'],
     incremental_strategy='delete+insert'
) }}

{% set SONIC_LAUNCH = '2024-12-18' %}

with transactions as (select * from {{ ref('stg_transactions') }}),

{% if is_incremental() %}
    last_loaded as (
        select max(block_date) as max_day
        from {{ this }}
    ),
{% else %}
last_loaded AS (
    SELECT toDate('{{ SONIC_LAUNCH }}') - 1 AS max_day
),
{% endif %}

src as (
    select
        trans.block_timestamp as block_timestamp,
        trans.from_address as address,
        toDate(trans.block_timestamp) as block_date
    from transactions as trans
    inner join last_loaded on 1 = 1
    where block_date > max_day
),

first_transactions as (
    select
        address,
        MIN(block_date) as first_block_date
    from src
    where block_date >= toDate('{{ SONIC_LAUNCH }}')
    group by address
),

daily_pairs as (
    select
        block_date,
        address
    from src
    group by block_date, address
),

final as (
    select
        daily.block_date as block_date,
        daily.address as address,
        IF(daily.block_date = first_tx.first_block_date, 1, 0) as is_new_user
    from daily_pairs daily
    left join first_transactions first_tx using (address)
)

select
    block_date,
    address,
    is_new_user
from final
