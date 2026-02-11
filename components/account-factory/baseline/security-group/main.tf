locals {
  # Extract security groups from directory files
  # Each file contains a single security group object
  security_group_config_files = var.security_group_dir_path != null ? fileset(var.security_group_dir_path, "**/*.{json,yaml,yml}") : []

  file_security_groups = [
    for file in local.security_group_config_files : (
      endswith(file, ".yaml") || endswith(file, ".yml") ?
      yamldecode(file("${var.security_group_dir_path}/${file}")) :
      jsondecode(file("${var.security_group_dir_path}/${file}"))
    )
  ]

  # All security groups combined (direct + from files)
  all_security_groups = concat(var.security_groups, local.file_security_groups)

  # Create a map of security groups keyed by security_group_name for for_each
  security_groups_map = {
    for sg in local.all_security_groups :
    sg.security_group_name => sg
  }
}

# Create security groups using for_each
module "security_group" {
  for_each = local.security_groups_map
  source   = "../../../../modules/security-group"

  providers = {
    alicloud = alicloud
  }

  vpc_id              = var.vpc_id
  security_group_name = each.value.security_group_name
  description         = try(each.value.description, null)
  inner_access_policy = try(each.value.inner_access_policy, null)
  resource_group_id   = try(each.value.resource_group_id, null)
  security_group_type = try(each.value.security_group_type, "normal")
  tags                = try(each.value.tags, {})
  rules               = try(each.value.rules, [])
}

