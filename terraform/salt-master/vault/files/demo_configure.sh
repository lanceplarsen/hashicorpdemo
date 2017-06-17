#!/bin/bash

export VAULT_ADDR="http://127.0.0.1:8200"

vault auth $1
vault mount pki
vault mount-tune -max-lease-ttl=87600h pki
vault write pki/root/generate/internal common_name=vault.hashicorpdemo.com ttl=87600h
vault write pki/config/urls issuing_certificates="http://127.0.0.1:8200/v1/pki/ca" crl_distribution_points="http://127.0.0.1:8200/v1/pki/crl"
vault write pki/roles/nginx     allowed_domains="hashicorpdemo.com"     allow_subdomains="true" max_ttl="72h"
vault policy-write api_policy api_policy.hcl
