# Prepare vault for work with this project
### Начало работы
Для работы с Vault нужно залогиниться из командной строки:
```shell
export VAULT_ADDR=https://<URL>
vault login <hashicorp_vault_token>
```
Если установка новая (только что установлен HashiCorp Vault), проверить
```shell
vault secrets list
```
Если нет строки с путём `secret/`:
```
secret/       kv           kv_xxxx           n/a

```
То необходимо добавить версию 2:
```shell
vault secrets enable -path=secret -version=2 kv
```
После этого по команде vault secrets list должна появиться строка с путём `secret/`


### Подгрузить github token:
```shell
vault kv put secret/github/github_token token=<github_token>
```

### Policy
Пример политики установки authserver (backend + front-end):
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

### Подготовка .env файла
- .env файл сконвертировать в json, например, `authserver-backend.dev.env` конвертируем в `authserver-backend.dev.json`, и тоже самое для front-end:
```shell
echo '{'$(sed 's/^/"/; s/=/": "/; s/$/",/' authserver-backend.dev.env | tr -d '\n' | sed 's/,$//')'}' > authserver-backend.dev.json

echo '{'$(sed 's/^/"/; s/=/": "/; s/$/",/' authserver-frontend.dev.env | tr -d '\n' | sed 's/,$//')'}' > authserver-frontend.dev.json

```
- Затем загрузить его в Vault

```shell
vault kv put secret/authserver-backend/dev @authserver-backend.dev.json
vault kv put secret/authserver-frontend/dev @authserver-frontend.dev.json

```

### Prepare new token for terraform access:
```bash
vault token create -policy=authserver_back_front -ttl=720h
```
Скопировать токен и разместить в файле `.vault-tokens`
```
tokens:
  dev:
    authserver_dev: "<token>"
```
