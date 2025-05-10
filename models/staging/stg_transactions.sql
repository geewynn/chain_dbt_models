{{
    config(
        materialized='view'
         )
}}

with source as (
    select * from {{ source('raw', 'transactions_new_data') }}
),

transformed_transactions as (
    select
    -- Primary keys
        `hash` as transaction_hash,
        blockhash as block_hash,
        blobversionedhashes as blob_versioned_hashes,

        -- Block relationship
        from_address,
        to_address,

        -- Transaction metadata
        r,
        s,
        v,
        `type`,

        input,
        reinterpretAsUInt32(reverse(unhex(replaceAll(transactionindex, '0x', ''))))
            as transaction_index,
        reinterpretAsUInt64(reverse(unhex(replaceAll(blocknumber, '0x', '')))) as block_number,
        reinterpretAsUInt64(reverse(unhex(replaceAll(timestamp, '0x', '')))) as block_timestamp,
        reinterpretAsUInt64(reverse(unhex(replaceAll(chainid, '0x', '')))) as chain_id,

        -- EIP-1559 fields
        reinterpretAsUInt64(reverse(unhex(replaceAll(gas, '0x', '')))) as gas,
        reinterpretAsUInt256(reverse(unhex(replaceAll(gasprice, '0x', '')))) as gas_price,
        reinterpretAsUInt64(reverse(unhex(replaceAll(number, '0x', '')))) as transaction_number,

        reinterpretAsUInt64(reverse(unhex(replaceAll(nonce, '0x', '')))) as nonce,
        reinterpretAsUInt256(reverse(unhex(replaceAll(value, '0x', '')))) as value,
        if(
            maxfeeperblobgas = '',
            null,
            reinterpretAsUInt256(reverse(unhex(replaceAll(maxfeeperblobgas, '0x', ''))))
        ) as max_fee_per_blob_gas,

        reinterpretAsUInt256(reverse(unhex(replaceAll(maxfeepergas, '0x', '')))) as max_fee_per_gas,
        reinterpretAsUInt256(reverse(unhex(replaceAll(maxpriorityfeepergas, '0x', ''))))
            as max_priority_fee_per_gas,

        now() as dbt_loaded_at
    from source
)

select * from transformed_transactions
