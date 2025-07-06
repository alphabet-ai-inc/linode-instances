locals {
  tokens = fileexists("~/.vault_tokens") ? yamldecode(file("~/.vault_tokens"))["tokens"] : {}
}

variable "vault_url" {
  type    = string
  default = "https://vault.sushkovs.ru"
}

provider "vault" {
  address          = var.vault_url
  token            = local.tokens[var.env][var.server_group_name]
  skip_child_token = true
}

data "vault_generic_secret" "app_env" {
  for_each = { for app in var.app : app.name => app }
  path     = "secret/${each.key}/${var.env}"
}

# Create temporary .env-files locally
resource "local_file" "app_env" {
  for_each = { for app in var.app : app.name => app }
  content  = join("\n", [for k, v in data.vault_generic_secret.app_env[each.key].data : "${k}=${v}"])
  filename = "${path.module}/tmp/${each.key}.${var.env}.env"
}

resource "local_file" "apps_json" {
  content  = jsonencode(var.app)
  filename = "${path.module}/tmp/apps.json"
}

# # Policy for every application (limited access)
# resource "vault_policy" "cicd" {
#   count = length(var.app)
#   name  = "cicd-policy-${var.app[count.index].name}-${var.env}"

#   policy = <<EOT
# # Read secrets only for one application and environment
# path "secret/data/${var.app[count.index].name}/${var.env}/env" {
#   capabilities = ["read"]
# }

# # Read application CI/CD token
# path "secret/data/${var.app[count.index].name}/${var.env}/cicd_token" {
#   capabilities = ["read"]
# }

# # Read SSH keys for server group
# path "secret/data/ssh/${var.server_group_name}/*" {
#   capabilities = ["read"]
# }
# EOT
# }

# # Create a separate token for CI/CD
# resource "vault_token" "cicd" {
#   count = length(var.app)

#   policies = ["cicd-policy-${var.app[count.index].name}-${var.env}"]

#   renewable = true
#   ttl       = "240h" # 10 дней

#   metadata = {
#     purpose      = "CI/CD deployments"
#     application  = var.app[count.index].name
#     environment  = var.env
#     server_group = var.server_group_name
#   }
#   depends_on = [vault_policy.cicd]
# }
