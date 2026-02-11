# Create EIP addresses
resource "alicloud_eip_address" "eip_address" {
  count = length(var.eip_instances)

  address_name              = var.eip_instances[count.index].eip_address_name
  payment_type              = var.eip_instances[count.index].payment_type
  period                    = var.eip_instances[count.index].period
  pricing_cycle             = var.eip_instances[count.index].pricing_cycle
  auto_pay                  = var.eip_instances[count.index].auto_pay
  bandwidth                 = var.eip_instances[count.index].bandwidth
  deletion_protection       = var.eip_instances[count.index].deletion_protection
  description               = var.eip_instances[count.index].description
  internet_charge_type      = var.eip_instances[count.index].internet_charge_type
  ip_address                = var.eip_instances[count.index].ip_address
  isp                       = var.eip_instances[count.index].isp
  mode                      = var.eip_instances[count.index].mode
  netmode                   = var.eip_instances[count.index].netmode
  public_ip_address_pool_id = var.eip_instances[count.index].public_ip_address_pool_id
  resource_group_id         = var.eip_instances[count.index].resource_group_id
  security_protection_types = var.eip_instances[count.index].security_protection_type != null && var.eip_instances[count.index].security_protection_type != "" ? [var.eip_instances[count.index].security_protection_type] : []
  zone                      = var.eip_instances[count.index].zone
  tags                      = var.eip_instances[count.index].tags
}

# Associate EIPs with instance
resource "alicloud_eip_association" "eip_association" {
  for_each = var.eip_associate_instance_id != "" ? {
    for idx, eip in alicloud_eip_address.eip_address :
    eip.id => eip.id
  } : {}

  allocation_id = each.value
  instance_id   = var.eip_associate_instance_id
}

