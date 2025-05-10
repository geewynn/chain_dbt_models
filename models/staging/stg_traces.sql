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
        transactionhash as transaction_hash,
        transactionposition as transaction_position,

        -- Blockchain location
        blockhash as block_hash,
        blocknumber,

        -- Call information
        calltype as call_type,
        from_address,
        to_address,
        trace_type,

        -- Call data
        input,
        `output` as call_output,

        -- Numeric fields - handle the hex conversion
        subtraces,
        traceaddress as trace_address,
        reinterpretAsUInt64(reverse(unhex(replaceAll(gas, '0x', '')))) as gas,
        reinterpretAsUInt256(reverse(unhex(replaceAll(value, '0x', '')))) as value,

        -- Trace structure
        reinterpretAsUInt64(reverse(unhex(replaceAll(gasused, '0x', '')))) as gas_used,

        -- Metadata
        now() as dbt_loaded_at
    from source
)

select * from transformed_logs
