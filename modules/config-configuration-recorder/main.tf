# Enable Config service (Configuration Recorder)
# Note: enterprise_edition is deprecated. Creating aggregator will automatically upgrade to enterprise edition.
# Setting this param will cause issues when importing state, so it's ignored.
resource "alicloud_config_configuration_recorder" "this" {
  lifecycle {
    ignore_changes = [
      resource_types,
      enterprise_edition
    ]
  }
}
