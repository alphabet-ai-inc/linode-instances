node_count              = 1
node_name_prefix        = "worker-node"
image_id                = "linode/ubuntu24.04"
region                  = "us-ord"
infra_backend_state_key = "states/infra/dev/tfstate"
authorized_users        = ["jpassano", "ssouchkov"]
git_repositories = [
  "https://github.com/alphabet-ai-inc/authserver"
]
app = [
  {
    name      = "authserver"
    url       = "https://github.com/alphabet-ai-inc/authserver"
    directory = "/app/authserver"
    commands = [
      "git checkout main",
      "docker network create authserver-network || true",
      "until docker compose up -d; do sleep 2; done",
      "timeout 60 bash -c 'while ! nc -z localhost 8080; do sleep 1; done'"
    ]
  },
  {
    name      = "authserver_front_end"
    url       = "https://github.com/alphabet-ai-inc/authserver_front_end"
    directory = "/app/authserver_front_end"
    commands = [
      "git checkout main",
      "docker compose up -d"
    ]
  }
]

bucket_name   = "infra-config"
bucket_region = "us-ord"
vault_url     = "https://vault.sushkovs.ru"

