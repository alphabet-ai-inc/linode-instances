node_count              = 1
node_name_prefix        = "authserver_dev"
image_id                = "linode/ubuntu24.04"
region                  = "us-ord"
infra_backend_state_key = "states/infra/dev/tfstate"
authorized_users        = ["jpassano", "ssouchkov"]
server_group_name       = "authserver_dev"
# git_repositories = [
#   "https://github.com/alphabet-ai-inc/authserver"
# ]
app = [
  {
    name      = "authserver-backend"
    url       = "https://github.com/alphabet-ai-inc/authserver-backend"
    directory = "/app/authserver-backend"
    commands = [
      "git checkout main",
      "docker network create authserver-network || true",
      "until docker compose up -d; do sleep 2; done",
      "timeout 60 bash -c 'while ! nc -z localhost 8080; do sleep 1; done'"
    ]
  },
  {
    name      = "authserver-frontend"
    url       = "https://github.com/alphabet-ai-inc/authserver-frontend"
    directory = "/app/authserver-frontend"
    commands = [
      "git checkout main",
      "docker compose up -d"
    ]
  }
]

bucket_name             = "infra-config"
bucket_region           = "us-ord"
vault_url               = "http://45.79.25.144:8200/"
github_token_vault_path = "secret/github/github_token"
github_owner            = "alphabet-ai-inc"
