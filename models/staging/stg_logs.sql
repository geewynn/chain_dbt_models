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
        blockHash as block_hash,
        reinterpretAsUInt64(reverse(unhex(replaceAll(blockNumber, '0x', '')))) as block_number,
        transactionHash as transaction_hash,
        reinterpretAsUInt32(reverse(unhex(replaceAll(logIndex, '0x', '')))) as log_index,

        -- Log content
        `address`,
        topics,
        `data`,
        
        -- Status
        removed,
        
        -- Metadata
        now() as dbt_loaded_at
    from source
)

select * from transformed_logs