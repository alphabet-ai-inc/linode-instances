### Requirements
1. Terraform v1.12.1 installed

2. Linode account with API key for read/write:
- Linodes
- Events

3. `~/.linode_credentials`
Example :
```ini
[linode]
aws_access_key_id=<your_access_key>
aws_secret_access_key=<your_secret_key>

```

3. `~/.linode_config`
Example :
```ini
[profile linode]
region = us-ord
output = text
```

Before terraform apply execute:
```bash
export AWS_REQUEST_CHECKSUM_CALCULATION=when_required  
export AWS_RESPONSE_CHECKSUM_VALIDATION=when_required
```