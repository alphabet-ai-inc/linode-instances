## Requirements
### 1. Terraform v1.12.1 installed

### 2. Linode account with API key for read/write:
- Linodes
- Events

### 3. `~/.linode_credentials`
Example :
```ini
[linode]
aws_access_key_id=<your_access_key>
aws_secret_access_key=<your_secret_key>

```

### 4. `~/.linode_config`
Example :
```ini
[profile linode]
region = us-ord
output = text
```
### 5. `~/.linode_token`
Example:
```
a4932c4a2d8d755d22be6c26bd80b67bd6cc846e87623cfa413dd63bfb7e87bb
```

### 6. `~/.vault_tokens`
Example:
```yml
tokens:
  dev:
    authserver_dev: "<yout_token_with_necessary_policy_permissions>"

```
where:
`dev` should match the `env` variable
`authserver_dev` should match the `server_group_name` variable


### Before terraform apply or destroy execute:
```bash
export AWS_REQUEST_CHECKSUM_CALCULATION=when_required  
export AWS_RESPONSE_CHECKSUM_VALIDATION=when_required
```
[Example of linode object storage as terraform backend](https://dev.to/itmecho/setting-up-linode-object-storage-as-a-terraform-backend-1ocb)

Problem:
[hashicorp/terraform#36704](https://github.com/hashicorp/terraform/issues/36704)

Solution:
[linode/terraform-provider-linode#1834](https://github.com/linode/terraform-provider-linode/issues/1834)
