{{
    config(
        materialized='view'
         )
}}

with source as (
    select * from {{ source('raw', 'logs_new_data') }}
),

transformed_logs as (
    select
        blockhash as block_hash,
        transactionhash as transaction_hash,
        `address`,
        topics,

        -- Log content
        `data`,
        removed,
        reinterpretasuint64(reverse(unhex(replaceall(blocknumber, '0x', ''))))
            as block_number,

        -- Status
        reinterpretasuint32(reverse(unhex(replaceall(logindex, '0x', ''))))
            as log_index,

        -- Metadata
        now() as dbt_loaded_at
    from source
)

select * from transformed_logs
