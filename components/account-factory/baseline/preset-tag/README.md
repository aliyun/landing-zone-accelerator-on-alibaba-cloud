<div align="right">

**English** | [中文](README-CN.md)

</div>

# Preset Tag Module

This module creates and manages Alibaba Cloud preset tags (meta tags) that can be used across resources.

## Features

- Creates preset tags with keys and values
- Supports multiple values per tag key

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |

## Modules

No modules.

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_tag_meta_tag.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/tag_meta_tag) | resource | Preset tags (meta tags) |

## Usage

```hcl
module "preset_tag" {
  source = "./components/account-factory/baseline/preset-tag"

  preset_tags = [
    {
      key    = "Environment"
      values = ["production", "staging", "development"]
    },
    {
      key    = "Project"
      values = ["landing-zone"]
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `preset_tags` | List of preset tags to create | `list(object)` | `[]` | No | See preset tag structure below |

### Preset Tag Object Structure

Each preset tag in `preset_tags` must have the following structure:

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| `key` | `string` | Yes | Tag key | 1-128 characters, cannot start with "aliyun" or "acs:", cannot contain "http://" or "https://" |
| `values` | `list(string)` | Yes | List of tag values | 1-10 values, each value max 128 characters, cannot contain "http://" or "https://" |

## Outputs

This module does not provide any outputs.

## Examples

### Basic Preset Tags

```hcl
module "preset_tag" {
  source = "./components/account-factory/baseline/preset-tag"

  preset_tags = [
    {
      key    = "Environment"
      values = ["production"]
    }
  ]
}
```

### Multiple Preset Tags

```hcl
module "preset_tag" {
  source = "./components/account-factory/baseline/preset-tag"

  preset_tags = [
    {
      key    = "Environment"
      values = ["production", "staging", "development"]
    },
    {
      key    = "Project"
      values = ["landing-zone", "application"]
    },
    {
      key    = "Team"
      values = ["devops", "backend", "frontend"]
    }
  ]
}
```

## Notes

- Preset tags (meta tags) are reusable tags that can be applied to resources
- Tag keys cannot start with "aliyun" or "acs:" prefixes
- Tag keys and values cannot contain "http://" or "https://"
- Each tag key can have 1-10 values
- Tag values are limited to 128 characters each
- Preset tags help maintain consistent tagging across resources
