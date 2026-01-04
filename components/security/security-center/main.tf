# Get current account information
data "alicloud_account" "current" {}

# Enable Security Center service (Threat Detection)
resource "alicloud_threat_detection_instance" "main" {
  count = var.enable_security_center ? 1 : 0

  payment_type = var.security_center_payment_type
  version_code = var.security_center_instance_type
  buy_number   = var.security_center_buy_number

  modify_type  = var.modify_type != null ? var.modify_type : null

  depends_on = [alicloud_security_center_service_linked_role.main]
}

# Create Security Center service-linked role
resource "alicloud_security_center_service_linked_role" "main" {
  count = var.enable_security_center ? 1 : 0
}