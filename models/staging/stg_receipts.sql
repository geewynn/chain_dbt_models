{{
    config(
        materialized='view'
         )
}}

with source as (
    select * from {{ source('raw', 'receipts_new_data') }}
),

transformed_receipts as (
    select
        -- Primary keys
        transactionHash as transaction_hash,
        reinterpretAsUInt32(reverse(unhex(replaceAll(transactionIndex, '0x', '')))) as transaction_index,
        blockHash as block_hash,
        reinterpretAsUInt64(reverse(unhex(replaceAll(blockNumber, '0x', '')))) as block_number,

        -- Contract info
        contractAddress as contract_address,

        -- From/To addresses (with backticks in source)
        `from` as from_address,
        `to` as to_address,

        -- Numeric fields - convert hex to numeric values
        reinterpretAsUInt64(reverse(unhex(replaceAll(cumulativeGasUsed, '0x', '')))) as cumulative_gas_used,
        reinterpretAsUInt256(reverse(unhex(replaceAll(effectiveGasPrice, '0x', '')))) as effective_gas_price,
        reinterpretAsUInt64(reverse(unhex(replaceAll(gasUsed, '0x', '')))) as gas_used,
        reinterpretAsUInt8(reverse(unhex(replaceAll(status, '0x', '')))) as status,

        -- Complex logs array (preserving original structure)
        logs,

        -- Additional fields
        logsBloom as logs_bloom,
        `type`,

        -- Metadata
        now() as dbt_loaded_at
    from source
)

select * from transformed_receipts
