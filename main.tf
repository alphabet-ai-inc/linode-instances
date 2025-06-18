data "terraform_remote_state" "infra_base" {
  backend = "s3"

  config = {
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true

    shared_credentials_files = ["~/.linode_credentials"]
    shared_config_files      = ["~/.linode_config"]
    profile                  = "linode"

    bucket = "infra-config"
    key    = var.infra_backend_state_key
    region = var.region

    endpoints = {
      s3 = "https://us-ord-1.linodeobjects.com"
    }
    use_path_style = true
  }
}

resource "random_password" "vm_root_password" {
  count            = var.node_count
  length           = 16
  special          = true
  override_special = "!@#$%^&*"
}

resource "linode_instance" "app_node" {
  count            = var.node_count
  depends_on       = [null_resource.env_validation, local_file.app_env, local_file.apps_json]
  label            = "${var.node_name_prefix}-${count.index + 1}"
  region           = data.terraform_remote_state.infra_base.outputs.region
  type             = var.instance_type
  image            = var.image_id
  root_pass        = random_password.vm_root_password[count.index].result
  authorized_keys  = ["${chomp(file(var.ssh_pub_key_file))}"]
  authorized_users = var.authorized_users

  interface {
    purpose = "public"
  }

  interface {
    purpose   = "vpc"
    subnet_id = data.terraform_remote_state.infra_base.outputs.subnet_id
  }

  firewall_id = data.terraform_remote_state.infra_base.outputs.firewall_id

  connection {
    type     = "ssh"
    user     = "root"
    password = random_password.vm_root_password[count.index].result
    host     = self.ip_address
  }

  provisioner "file" {
    source      = "${path.module}/tmp/apps.json"
    destination = "/tmp/apps.json"
  }


  provisioner "file" {
    source      = "setup_script.sh"
    destination = "/tmp/setup_script.sh"
  }

}

resource "null_resource" "copy_env_files" {
  for_each   = { for app in var.app : app.name => app }
  depends_on = [linode_instance.app_node, local_file.app_env]

  connection {
    type     = "ssh"
    user     = "root"
    password = element(random_password.vm_root_password[*].result, 0)
    host     = element(linode_instance.app_node[*].ip_address, 0)
  }

  provisioner "file" {
    source      = "${path.module}/tmp/${each.key}.${var.env}.env"
    destination = "/tmp/${each.key}.${var.env}.env"
  }
}

resource "null_resource" "run_setup_script" {
  count      = var.node_count
  depends_on = [linode_instance.app_node, null_resource.copy_env_files]

  connection {
    type     = "ssh"
    user     = "root"
    password = element(random_password.vm_root_password[*].result, 0)
    host     = element(linode_instance.app_node[*].ip_address, 0)
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup_script.sh",
      "ENV=${var.env} /tmp/setup_script.sh",
    ]
  }
}
