resource "tls_private_key" "github_actions" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key in Vault
resource "vault_generic_secret" "github_ssh_private_key" {
  path = "secret/ssh/${var.server_group_name}/private_key"

  data_json = jsonencode({
    private_key = tls_private_key.github_actions.private_key_pem
  })
}

# Save public key in Vault
resource "vault_generic_secret" "github_ssh_public_key" {
  path = "secret/ssh/${var.server_group_name}/public_key"

  data_json = jsonencode({
    public_key = tls_private_key.github_actions.public_key_openssh
  })
}

# Add public key to servers
resource "null_resource" "setup_github_ssh" {
  count = var.node_count

  depends_on = [linode_instance.app_node]

  provisioner "remote-exec" {
    inline = [
      "echo '${tls_private_key.github_actions.public_key_openssh}' >> ~/.ssh/authorized_keys",
      "chmod 600 ~/.ssh/authorized_keys",
      "chown root:root ~/.ssh/authorized_keys"
    ]

    connection {
      type     = "ssh"
      user     = "root"
      password = random_password.vm_root_password[count.index].result
      host     = linode_instance.app_node[count.index].ip_address
    }
  }

  triggers = {
    instance_id = linode_instance.app_node[count.index].id
    public_key  = tls_private_key.github_actions.public_key_openssh
  }
}