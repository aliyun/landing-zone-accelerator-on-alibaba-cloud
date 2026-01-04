output "kms_instance_id" {
  description = "The ID of the KMS instance"
  value       = try(module.kms_instance[0].kms_instance_id, null)
}

output "kms_instance_status" {
  description = "The status of the KMS instance"
  value       = try(module.kms_instance[0].kms_instance_status, null)
}

output "kms_instance_name" {
  description = "The name of the KMS instance"
  value       = try(module.kms_instance[0].kms_instance_name, null)
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = try(alicloud_vpc.kms_vpc[0].id, null)
}

output "vswitch_id" {
  description = "The ID of the VSwitch"
  value       = try(alicloud_vswitch.kms_vswitch[0].id, null)
}

output "vswitch_ids" {
  description = "The IDs of all VSwitches"
  value       = try([alicloud_vswitch.kms_vswitch[0].id], [])
}

output "zone_ids" {
  description = "The zone IDs used by the KMS instance"
  value       = try(var.zone_ids, [])
}
