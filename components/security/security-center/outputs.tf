output "security_center_instance_id" {
  description = "The ID of the Security Center instance"
  value       = try(alicloud_threat_detection_instance.main[0].id, null)
}

output "security_center_instance_status" {
  description = "The status of the Security Center instance"
  value       = try(alicloud_threat_detection_instance.main[0].status, null)
}

output "security_center_service_linked_role" {
  description = "The Security Center service-linked role"
  value       = try(alicloud_security_center_service_linked_role.main[0].id, null)
}

output "security_center_instance_type" {
  description = "The type of the Security Center instance"
  value       = var.security_center_instance_type
}