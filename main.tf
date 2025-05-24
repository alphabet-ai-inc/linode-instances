data "terraform_remote_state" "infra_base" {
  backend = "local"
  config = {
    path = "../linode-infra-base/terraform.tfstate"
  }
}

resource "random_password" "vm_root_password" {
  count       = var.node_count
  length      = 16
  special     = true
  override_special = "!@#$%^&*"
}

resource "linode_instance" "app_node" {
  count       = var.node_count
  label       = "${var.node_name_prefix}-${count.index + 1}"
  region      = data.terraform_remote_state.infra_base.outputs.region
  type        = var.instance_type
  image       = var.image_id
  root_pass   = random_password.vm_root_password[count.index].result

  interface {
    purpose   = "vpc"
    subnet_id = data.terraform_remote_state.infra_base.outputs.subnet_id
    ipv4 {
      vpc = "10.0.1.${10 + count.index}"
    }
  }

  interface {
    purpose = "public"
  }

  firewall_id = data.terraform_remote_state.infra_base.outputs.firewall_id

}