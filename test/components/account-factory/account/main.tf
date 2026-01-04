provider "alicloud" {
  region = "cn-hangzhou"
}

module "account" {
  source = "../../../../components/account-factory/account"

  account_name_prefix = "example-account"
  display_name        = "example-account"
  billing_type        = "Trusteeship"
}

output "account_id" {
  value = module.account.account_id
}
output "display_name" {
  value = module.account.display_name
}
