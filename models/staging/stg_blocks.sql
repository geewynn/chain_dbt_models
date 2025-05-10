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
        parenthash as parent_hash,
        sha3uncles as sha3_uncles,
        miner,
        stateroot as state_root,
        transactionsroot as transactions_root,
        receiptsroot as receipts_root,
        logsbloom as logs_bloom,
        extradata as extra_data,

        mixhash as mix_hash,
        nonce,
        withdrawalsroot as withdrawals_root,
        uncles,
        reinterpretasuint256(reverse(unhex(replace(number, '0x', ''))))
            as block_number,

        -- Additional fields
        reinterpretasuint256(reverse(unhex(replace(difficulty, '0x', ''))))
            as difficulty,
        reinterpretasuint64(reverse(unhex(replace(gaslimit, '0x', ''))))
            as gas_limit,
        reinterpretasuint64(reverse(unhex(replace(gasused, '0x', ''))))
            as gas_used,
        reinterpretasuint64(reverse(unhex(replace(timestamp, '0x', ''))))
            as block_timestamp,
        reinterpretasuint64(reverse(unhex(replace(timestampnano, '0x', ''))))
            as timestamp_nano,
        reinterpretasuint256(reverse(unhex(replace(basefeepergas, '0x', ''))))
            as base_fee_per_gas,

        reinterpretasuint64(reverse(unhex(replace(epoch, '0x', '')))) as epoch,
        reinterpretasuint256(
            reverse(unhex(replace(totaldifficulty, '0x', '')))
        ) as total_difficulty,
        reinterpretasuint64(reverse(unhex(replace(blobgasused, '0x', ''))))
            as blob_gas_used,
        reinterpretasuint64(reverse(unhex(replace(excessblobgas, '0x', ''))))
            as excess_blob_gas,

        reinterpretasuint64(reverse(unhex(replace(size, '0x', '')))) as size,
        current_timestamp() as dbt_loaded_at
    from source
)

select * from transformed_blocks
