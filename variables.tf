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
    description  = "Image ID"
    type         = string
}
