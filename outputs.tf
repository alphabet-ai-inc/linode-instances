output "instance_ids" {
  description = "IDs of the created Linode instances"
  value       = linode_instance.app_node[*].id
}

output "instance_ips" {
  description = "IP addresses of the created Linode instances"
  value       = [for instance in linode_instance.app_node : instance.ip_address]
}

output "vm_password" {
  value     = random_password.vm_root_password[0].result
  sensitive = true
}
