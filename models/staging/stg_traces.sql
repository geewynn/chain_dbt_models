{{
    config(
        materialized='view'
         )
}}

with source as (
    select * from {{ source('raw', 'traces_new_data') }}
),

transformed_logs as (
    select
        -- Primary keys
        transactionHash as transaction_hash,
        transactionPosition as transaction_position,

        -- Blockchain location
        blockHash as block_hash,
        blockNumber,

        -- Call information
        callType as call_type,
        from_address,
        to_address,
        trace_type,

        -- Call data
        input,
        `output`,

        -- Numeric fields - handle the hex conversion
        reinterpretAsUInt64(reverse(unhex(replaceAll(gas, '0x', '')))) as gas,
        reinterpretAsUInt256(reverse(unhex(replaceAll(value, '0x', '')))) as value,
        reinterpretAsUInt64(reverse(unhex(replaceAll(gasUsed, '0x', '')))) as gas_used,
        subtraces,

        -- Trace structure
        traceAddress as trace_address,

        -- Metadata
        now() as dbt_loaded_at
    from source
)

select * from transformed_logs
