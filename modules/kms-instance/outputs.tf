output "kms_instance_id" {
  description = "The ID of the KMS instance"
  value       = alicloud_kms_instance.this.id
}

output "kms_instance_status" {
  description = "The status of the KMS instance"
  value       = alicloud_kms_instance.this.status
}

output "kms_instance_name" {
  description = "The name of the KMS instance"
  value       = alicloud_kms_instance.this.instance_name
}

