# https://registry.terraform.io/providers/linode/linode/latest/docs
# https://registry.terraform.io/providers/linode/linode/latest/docs
terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.40.0"
    }
  }
  backend "s3" {
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
    shared_credentials_files    = ["~/.linode_credentials"]
    shared_config_files         = ["~/.linode_config"]
    profile                     = "linode"
    bucket                      = "infra-config"
    key                         = "states/instances/dev/tfstate"
    region                      = "us-ord"
    endpoints = {
      s3 = "https://us-ord-1.linodeobjects.com"
    }
  }
}

provider "linode" {
  token = trimspace(file("~/.linode_token"))
}
