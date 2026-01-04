output "zone_id" {
  description = "Application Private Zone ID"
  value       = alicloud_pvtz_zone.this.id
}

output "zone_record_ids" {
  description = "Application Private Zone record ID list"
  value       = [for r in alicloud_pvtz_zone_record.this : r.id]
}
