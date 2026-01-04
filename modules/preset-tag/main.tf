# Create preset tags (meta tags)
resource "alicloud_tag_meta_tag" "this" {
  for_each = {
    for tag in var.preset_tags : tag.key => tag.values
  }

  key    = each.key
  values = each.value
}
