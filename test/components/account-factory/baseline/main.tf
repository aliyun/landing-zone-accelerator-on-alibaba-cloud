provider "alicloud" {
  alias  = "default"
  region = "cn-hangzhou"
}

provider "alicloud" {
  alias  = "vpc_sh"
  region = "cn-shanghai"
}

provider "alicloud" {
  alias  = "vpc_bj"
  region = "cn-beijing"
}

provider "alicloud" {
  alias  = "cen_tr_sh"
  region = "cn-shanghai"
}

provider "alicloud" {
  alias  = "cen_tr_bj"
  region = "cn-beijing"
}

# Service Linked Role
module "slr" {
  source  = "terraform-alicloud-modules/service-linked-role/alicloud"
  version = "1.2.0"

  providers = {
    alicloud = alicloud.default
  }

  service_linked_role_with_service_names = [
    "cen"
  ]
}
