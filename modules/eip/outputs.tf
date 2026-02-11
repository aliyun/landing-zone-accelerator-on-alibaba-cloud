output "eip_instances" {
  description = "List of EIP instances with details including ID, IP address, and association ID."
  value = [
    for idx, eip in alicloud_eip_address.eip_address : {
      id             = eip.id
      ip_address     = eip.ip_address
      address_name   = eip.address_name
      payment_type   = eip.payment_type
      status         = eip.status
      association_id = var.eip_associate_instance_id != "" ? alicloud_eip_association.eip_association[eip.id].id : null
    }
  ]
}

output "eip_ids" {
  description = "List of EIP IDs."
  value       = [for eip in alicloud_eip_address.eip_address : eip.id]
}

output "eip_ips" {
  description = "List of EIP IP addresses."
  value       = [for eip in alicloud_eip_address.eip_address : eip.ip_address]
}


