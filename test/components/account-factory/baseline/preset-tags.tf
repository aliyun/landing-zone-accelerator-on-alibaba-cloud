# Preset Tags
module "preset_tags" {
  source = "../../../../components/account-factory/baseline/preset-tag"

  providers = {
    alicloud = alicloud.default
  }

  preset_tags = [
    {
      key    = "Environment"
      values = ["default", "dev", "test", "prod"]
    },
    {
      key    = "Project"
      values = ["landing-zone"]
    }
  ]
}

output "preset_tags" {
  description = "Preset tags output"
  value       = module.preset_tags
}

