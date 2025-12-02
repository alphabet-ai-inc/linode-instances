# Prepare vault for work with this project
### Getting Started
To work with Vault, you need to log in from the command line:
```shell
export VAULT_ADDR=https://<URL>
vault login <hashicorp_vault_token>
```
If the installation is new (HashiCorp Vault just installed), check
```shell
vault secrets list
```
If there is no line with the `secret/` path:
```
secret/       kv           kv_xxxx           n/a

```
Then you need to add version 2:
```shell
vault secrets enable -path=secret -version=2 kv
```
After this, the command vault secrets list should display a line with the path `secret/`


### Add github token:
```shell
vault kv put secret/github/github_token token=<github_token>
```

### Policy
Example of installation policy authserver (backend + front-end):
name: authserver_back_front
```hcl
# For terraform project linode-instances for authserver and authserver-frontend
path "secret/data/authserver-backend/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/authserver-frontend/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/github/github_token" {
  capabilities = ["create", "read", "update", "delete"]
}

path "secret/data/ssh/authserver_dev/*" {
  capabilities = ["create", "read", "update", "delete"]
}

path "sys/policies/acl/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "auth/token/create" {
  capabilities = ["create", "update", "delete", "list"]
}

```

### Preparing the .env file
- Convert the .env file to json, for example, convert `authserver-backend.dev.env` to `authserver-backend.dev.json`, and the same for the front-end:
```shell
echo '{'$(sed 's/^/"/; s/=/": "/; s/$/",/' authserver-backend.dev.env | tr -d '\n' | sed 's/,$//')'}' > authserver-backend.dev.json

echo '{'$(sed 's/^/"/; s/=/": "/; s/$/",/' authserver-frontend.dev.env | tr -d '\n' | sed 's/,$//')'}' > authserver-frontend.dev.json

```
- Then upload it to the Vault
```shell
vault kv put secret/authserver-backend/dev @authserver-backend.dev.json
vault kv put secret/authserver-frontend/dev @authserver-frontend.dev.json

```

### Prepare new token for terraform access:
```bash
vault token create -policy=authserver_back_front -ttl=720h
```
Copy the token and place it in the `vault-tokens` file
```
tokens:
  dev:
    authserver_dev: "<token>"
```
