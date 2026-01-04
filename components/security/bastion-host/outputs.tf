# Output the Bastion Host instance ID
output "bastion_host_instance_id" {
  description = "The ID of the Bastion Host instance"
  value       = var.create_bastion_host ? join("", alicloud_bastionhost_instance.default[*].id) : ""
}

# Output the Bastion Host instance name
output "bastion_host_instance_name" {
  description = "The name of the Bastion Host instance"
  value       = var.create_bastion_host ? join("", alicloud_bastionhost_instance.default[*].description) : ""
}

# Output the Bastion Host security group name
output "security_group_name" {
  description = "The name of the security group"
  value       = var.create_bastion_host && var.create_vpc_resources ? alicloud_security_group.bastion_sg[0].security_group_name : var.security_group_name
}

# Output the Bastion Host VPC ID
output "bastion_host_vpc_id" {
  description = "The ID of the VPC for the Bastion Host"
  value       = var.create_bastion_host && var.create_vpc_resources ? alicloud_vpc.bastion_vpc[0].id : ""
}

# Output the Bastion Host VSwitch ID
output "bastion_host_vswitch_id" {
  description = "The ID of the VSwitch for the Bastion Host"
  value       = var.create_bastion_host && var.create_vpc_resources ? alicloud_vswitch.bastion_vswitch[0].id : ""
}

# Output the Bastion Host security group ID
output "bastion_host_security_group_id" {
  description = "The ID of the security group for the Bastion Host"
  value       = var.create_bastion_host && var.create_vpc_resources ? alicloud_security_group.bastion_sg[0].id : ""
}

# Output the Bastion Host role name
output "bastion_host_role_name" {
  description = "The name of the RAM role for Bastion Host service"
  value       = var.create_bastion_host ? join("", module.slr-with-service-name.service_linked_role_names) : ""
}

# Service Linked Role
output "service_linked_role_names" {
  description = "The name of the service linked roles"
  value       = module.slr-with-service-name.service_linked_role_names
}

# Output the Bastion Host VPC name
output "bastion_host_vpc_name" {
  description = "The name of the VPC for the Bastion Host"
  value       = var.create_bastion_host && var.create_vpc_resources ? alicloud_vpc.bastion_vpc[0].vpc_name : var.vpc_name
}

# Output the Bastion Host VSwitch name
output "bastion_host_vswitch_name" {
  description = "The name of the VSwitch for the Bastion Host"
  value       = var.create_bastion_host && var.create_vpc_resources ? alicloud_vswitch.bastion_vswitch[0].vswitch_name : var.vswitch_name
}