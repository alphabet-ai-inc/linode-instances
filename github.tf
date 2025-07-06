# Get GitHub token from Vault
data "vault_generic_secret" "github_token" {
  path = var.github_token_vault_path
}

# Get owner and repository name from URL
locals {
  github_repos = [
    for app in var.app : {
      owner     = split("/", split("github.com/", app.url)[1])[0]
      repo      = split("/", split("github.com/", app.url)[1])[1]
      directory = app.directory
      name      = app.name
    }
  ]
}

# Get repositories info
data "github_repository" "repos" {
  count     = length(local.github_repos)
  full_name = "${local.github_repos[count.index].owner}/${local.github_repos[count.index].repo}"
}

# Create secrets for each repository
resource "github_actions_secret" "ssh_private_key" {
  count           = length(local.github_repos)
  repository      = local.github_repos[count.index].repo
  secret_name     = "SSH_PRIVATE_KEY"
  plaintext_value = tls_private_key.github_actions.private_key_pem
}

resource "github_actions_secret" "servers" {
  count           = length(local.github_repos)
  repository      = local.github_repos[count.index].repo
  secret_name     = "SERVERS"
  plaintext_value = join(",", [for instance in linode_instance.app_node : instance.ip_address])
}

resource "github_actions_secret" "ssh_user" {
  count           = length(local.github_repos)
  repository      = local.github_repos[count.index].repo
  secret_name     = "SSH_USER"
  plaintext_value = var.ssh_user
}

resource "github_actions_secret" "vault_addr" {
  count           = length(local.github_repos)
  repository      = local.github_repos[count.index].repo
  secret_name     = "VAULT_ADDR"
  plaintext_value = var.vault_url
}

resource "github_actions_secret" "server_group" {
  count           = length(local.github_repos)
  repository      = local.github_repos[count.index].repo
  secret_name     = "SERVER_GROUP"
  plaintext_value = var.server_group_name
}

resource "github_actions_secret" "server_ips" {
  count           = length(local.github_repos)
  repository      = local.github_repos[count.index].repo
  secret_name     = "SERVER_IPS"
  plaintext_value = join(",", [for instance in linode_instance.app_node : instance.ip_address])
}



resource "github_actions_secret" "deploy_path" {
  count           = length(local.github_repos)
  repository      = local.github_repos[count.index].repo
  secret_name     = "DEPLOY_PATH"
  plaintext_value = local.github_repos[count.index].directory
}

resource "github_actions_secret" "vault_token" {
  count           = length(local.github_repos)
  repository      = local.github_repos[count.index].repo
  secret_name     = "VAULT_TOKEN"
  # plaintext_value = vault_token.cicd[count.index].client_token
  plaintext_value = local.tokens[var.env][var.server_group_name]
}

output "debug_repos" {
  value = data.github_repository.repos
}
