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
    reinterpretAsUInt32(reverse(unhex(replaceAll(transactionIndex, '0x', '')))) as transaction_index,
    reinterpretAsUInt64(reverse(unhex(replaceAll(blockNumber, '0x', '')))) as block_number,

    
    -- Block relationship
    blockHash as block_hash,
    reinterpretAsUInt64(reverse(unhex(replaceAll(timestamp, '0x', '')))) as block_timestamp,
    
    -- Transaction metadata
    blobVersionedHashes as blob_versioned_hashes,
    reinterpretAsUInt64(reverse(unhex(replaceAll(chainId, '0x', '')))) as chain_id,
    from_address,
    to_address,
    
    reinterpretAsUInt64(reverse(unhex(replaceAll(gas, '0x', '')))) as gas,
    reinterpretAsUInt256(reverse(unhex(replaceAll(gasPrice, '0x', '')))) as gas_price,
    reinterpretAsUInt64(reverse(unhex(replaceAll(number, '0x', '')))) as transaction_number,
    reinterpretAsUInt64(reverse(unhex(replaceAll(nonce, '0x', '')))) as nonce,
    reinterpretAsUInt256(reverse(unhex(replaceAll(value, '0x', '')))) as value,
    
    -- EIP-1559 fields
    if(maxFeePerBlobGas = '', null, reinterpretAsUInt256(reverse(unhex(replaceAll(maxFeePerBlobGas, '0x', ''))))) as max_fee_per_blob_gas,
    reinterpretAsUInt256(reverse(unhex(replaceAll(maxFeePerGas, '0x', '')))) as max_fee_per_gas,
    reinterpretAsUInt256(reverse(unhex(replaceAll(maxPriorityFeePerGas, '0x', '')))) as max_priority_fee_per_gas,
    
    r,
    s,
    v,
    
    `type`,
    input,
    
    now() as dbt_loaded_at
    from source
)

select * from transformed_transactions