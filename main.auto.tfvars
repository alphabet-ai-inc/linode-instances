node_count              = 1
node_name_prefix        = "worker-node"
image_id                = "linode/ubuntu24.04"
region                  = "us-ord"
infra_backend_state_key = "states/infra/dev/tfstate"
authorized_users        = ["jpassano", "ssouchkov"]
git_repositories = [
  "https://github.com/alphabet-ai-inc/authserver"
]
