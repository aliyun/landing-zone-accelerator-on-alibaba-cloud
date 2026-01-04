# Provider configuration
provider "alicloud" {
  region = "cn-hangzhou"
}

# Test security center component
module "security_center" {
  source = "../../../../components/security/security-center"

  enable_security_center        = true
  security_center_instance_type = "level2"
  security_center_payment_type  = "PayAsYouGo"
  modify_type                   = null
}

output "security_center_instance_id" {
  description = "The ID of the Security Center instance"
  value       = module.security_center.security_center_instance_id
}

output "security_center_instance_status" {
  description = "The status of the Security Center instance"
  value       = module.security_center.security_center_instance_status
}

output "security_center_service_linked_role" {
  description = "The Security Center service-linked role"
  value       = module.security_center.security_center_service_linked_role
}

output "security_center_instance_type" {
  description = "The type of the Security Center instance"
  value       = module.security_center.security_center_instance_type
}