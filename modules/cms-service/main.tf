resource "alicloud_cloud_monitor_service_basic_public" "basic" {
}

resource "alicloud_resource_manager_service_linked_role" "slr" {
  service_name = "cloudmonitor.aliyuncs.com"
}

resource "alicloud_cloud_monitor_service_enterprise_public" "enterprise" {
  count = var.enable_enterprise ? 1 : 0
}


