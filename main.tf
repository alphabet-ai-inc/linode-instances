data "terraform_remote_state" "infra_base" {
  backend = "s3"
  
  config = {
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum           = true
    
    shared_credentials_files = ["~/.linode_credentials"]
    shared_config_files      = ["~/.linode_config"]
    profile                 = "linode"
    
    bucket   = "infra-config"
    key      = var.infra_backend_state_key
    region   = var.region
    
    endpoints = {
      s3 = "https://us-ord-1.linodeobjects.com"
    }
    use_path_style = true
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