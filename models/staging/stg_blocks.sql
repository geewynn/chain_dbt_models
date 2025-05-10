{{
    config(
        materialized='view',
        unique_key='block_hash'
    )
}}

with source as (
    select * from {{ source('raw', 'blocks_new_data') }}
),

transformed_blocks as (
    select
        `hash` as block_hash,
        reinterpretAsUInt64(reverse(unhex(replace(number, '0x', '')))) as block_number,
        parentHash as parent_hash,
        sha3Uncles as sha3_uncles,
        miner,
        stateRoot as state_root,
        transactionsRoot as transactions_root,
        receiptsRoot as receipts_root,
        logsBloom as logs_bloom,
        
        reinterpretAsUInt256(reverse(unhex(replace(difficulty, '0x', '')))) as difficulty,
        reinterpretAsUInt64(reverse(unhex(replace(gasLimit, '0x', '')))) as gas_limit,
        reinterpretAsUInt64(reverse(unhex(replace(gasUsed, '0x', '')))) as gas_used,
        reinterpretAsUInt64(reverse(unhex(replace(timestamp, '0x', '')))) as block_timestamp,
        reinterpretAsUInt64(reverse(unhex(replace(timestampNano, '0x', '')))) as timestamp_nano,
        
        -- Additional fields
        extraData as extra_data,
        mixHash as mix_hash,
        nonce,
        reinterpretAsUInt256(reverse(unhex(replace(baseFeePerGas, '0x', '')))) as base_fee_per_gas,
        reinterpretAsUInt64(reverse(unhex(replace(epoch, '0x', '')))) as epoch,
        reinterpretAsUInt256(reverse(unhex(replace(totalDifficulty, '0x', '')))) as total_difficulty,
        
        withdrawalsRoot as withdrawals_root,
        reinterpretAsUInt64(reverse(unhex(replace(blobGasUsed, '0x', '')))) as blob_gas_used,
        reinterpretAsUInt64(reverse(unhex(replace(excessBlobGas, '0x', '')))) as excess_blob_gas,
        reinterpretAsUInt64(reverse(unhex(replace(size, '0x', '')))) as size,

        uncles,
        current_timestamp() as dbt_loaded_at
    from source
)

select * from transformed_blocks