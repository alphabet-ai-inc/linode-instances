# https://registry.terraform.io/providers/linode/linode/latest/docs
terraform { 
    required_providers { 
        linode = { 
            source = "linode/linode"
            version = "2.40.0" 
        } 
    } 
}

provider "linode" {
    token = file("~/.linode_token")
}
