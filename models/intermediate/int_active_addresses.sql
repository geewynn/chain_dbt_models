{{ 
    config(
     materialized='incremental',
     unique_key=['day', 'user'],
     incremental_strategy='delete+insert'
) }}

{% set SONIC_LAUNCH = '2024-12-18' %}


WITH transactions as (select * from {{ ref('stg_transactions') }}),
src AS (

    SELECT
        toDate(block_timestamp)             AS block_date,
        block_timestamp,
        from_address                        AS user
    FROM transactions
    /* ---- only pick up new dates when running incrementally ---- */
    {% if is_incremental() %}
        WHERE toDate(block_timestamp) > (SELECT max(day) FROM {{ this }})
    {% endif %}

),


first_transactions AS (

    SELECT
        user,
        MIN(block_date)  AS first_block_date
    FROM src                -- safe because src already filters incremental chunk
    WHERE block_date >= toDate('{{ SONIC_LAUNCH }}')
    GROUP BY user

),

daily_pairs AS (

    SELECT
        block_date AS day,
        user
    FROM src
    GROUP BY day, user

),


final AS (

    SELECT
        dp.day,
        dp.user,
        /* flag = 1 when today == wallet’s first ever txn date */
        IF(dp.day = fa.first_block_date, 1, 0) AS is_new_user
    FROM daily_pairs           dp
    LEFT JOIN first_transactions fa USING (user)

)

SELECT
    day,
    user,
    is_new_user
FROM final
