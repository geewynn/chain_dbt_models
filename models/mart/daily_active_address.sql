{{
    config(
        materialized='view'
         )
}}

with source as (
    select * from {{ ref('int_active_addresses') }}
)

SELECT
    day,
    COUNT(DISTINCT user) AS active_users,
    COUNT(DISTINCT IF(is_new_user = 1, user, NULL)) AS new_users,
    COUNT(DISTINCT IF(is_new_user = 0, user, NULL)) AS returning_users
FROM source
GROUP BY day
