locals {
  tokens = fileexists("~/.vault_tokens") ? yamldecode(file("~/.vault_tokens"))["tokens"] : {}
}

variable "vault_url" {
  type    = string
  default = "https://vault.sushkovs.ru"
}

provider "vault" {
  address          = var.vault_url
  token            = local.tokens[var.env][var.app[0].name]
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

output "env_authserver" {
  value = nonsensitive(data.vault_generic_secret.app_env[var.app[0].name].data)
  # sensitive = true
}
output "env_frontend" {
  value = nonsensitive(data.vault_generic_secret.app_env[var.app[1].name].data)
  # sensitive = true
}
