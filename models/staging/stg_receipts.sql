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
        transactionhash as transaction_hash,
        blockhash as block_hash,
        contractaddress as contract_address,
        `from` as from_address,

        -- Contract info
        `to` as to_address,

        -- From/To addresses (with backticks in source)
        logs,
        logsbloom as logs_bloom,

        -- Numeric fields - convert hex to numeric values
        `type`,
        reinterpretAsUInt32(reverse(unhex(replaceAll(transactionindex, '0x', ''))))
            as transaction_index,
        reinterpretAsUInt64(reverse(unhex(replaceAll(blocknumber, '0x', '')))) as block_number,
        reinterpretAsUInt64(reverse(unhex(replaceAll(cumulativegasused, '0x', ''))))
            as cumulative_gas_used,

        -- Complex logs array (preserving original structure)
        reinterpretAsUInt256(reverse(unhex(replaceAll(effectivegasprice, '0x', ''))))
            as effective_gas_price,

        -- Additional fields
        reinterpretAsUInt64(reverse(unhex(replaceAll(gasused, '0x', '')))) as gas_used,
        reinterpretAsUInt8(reverse(unhex(replaceAll(status, '0x', '')))) as status,

        -- Metadata
        now() as dbt_loaded_at
    from source
)

select * from transformed_receipts
