variable "node_name_prefix" {
  description = "Prefix for Linode instance names"
  type        = string
  default     = "app-node"
}

variable "instance_type" {
  description = "Linode instance type"
  type        = string
  default     = "g6-nanode-1"
}

variable "node_count" {
  description = "Number of Linode instances to create"
  type        = number
  default     = 2
}

variable "image_id" {
  description = "Image ID"
  type        = string
}

variable "region" {
  type    = string
  default = "us-ord"
}

variable "infra_backend_state_key" {
  type = string
}

variable "git_repositories" {
  description = "URL list with Git-repositories"
  type        = list(string)
  default     = []
}

variable "ssh_pub_key_file" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

variable "authorized_users" {
  type    = list(string)
  default = []
}