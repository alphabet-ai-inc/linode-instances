#!/bin/bash
export VAULT_ADDR="https://vault.example.com"
export VAULT_TOKEN="vault_token"
KEYS=("key1" "key2" "key3" "key4" "key5")
for key in "${KEYS[@]}"; do
  vault operator unseal $key
done