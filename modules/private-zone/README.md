<div align="right">

**English** | [中文](README-CN.md)

</div>

# Private Zone Module

This module creates and manages Alibaba Cloud Private DNS Zone resources, including zone creation, VPC bindings, and DNS record management.

## Features

- Creates Private DNS Zone with configurable proxy pattern
- Binds zone to multiple VPCs across different regions
- Manages DNS records (A, CNAME, TXT, MX, PTR, SRV)
- Automatically enables Private Zone service

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
| [alicloud_pvtz_service.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/pvtz_service) | data source | Private Zone service activation |
| [alicloud_pvtz_zone.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/pvtz_zone) | resource | Private DNS Zone |
| [alicloud_pvtz_zone_attachment.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/pvtz_zone_attachment) | resource | VPC bindings for the zone |
| [alicloud_pvtz_zone_record.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/pvtz_zone_record) | resource | DNS records within the zone |

## Usage

```hcl
module "private_zone" {
  source = "./modules/private-zone"

  zone_name     = "example.com"
  zone_remark   = "Example private zone"
  proxy_pattern = "ZONE"
  lang          = "en"
  
  vpc_bindings = [
    {
      vpc_id    = "vpc-uf6v10ktt3tnxxxxxxxx"
      region_id = "cn-hangzhou"
    }
  ]
  
  record_entries = [
    {
      name   = "www"
      type   = "A"
      value  = "192.168.1.1"
      ttl    = 60
      status = "ENABLE"
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `zone_name` | Application Private Zone name | `string` | - | Yes | - |
| `zone_remark` | Application Private Zone remark | `string` | `null` | No | Max 50 characters, only Chinese, English, numbers, '.', '_' or '-' |
| `proxy_pattern` | Recursive DNS proxy pattern | `string` | `"ZONE"` | No | Must be `"ZONE"` or `"RECORD"` |
| `lang` | Application Private Zone language | `string` | `"en"` | No | Must be `"zh"` or `"en"` |
| `resource_group_id` | The resource group ID which the Private Zone belongs to | `string` | `""` | No | - |
| `tags` | The tags of the Private Zone | `map(string)` | `{}` | No | - |
| `vpc_bindings` | VPC binding list for zone effective scope | `list(object)` | `[]` | No | Each item contains `vpc_id` (required) and `region_id` (optional) |
| `record_entries` | DNS record settings | `list(object)` | `[]` | No | See record object structure below |

### Record Entry Object Structure

Each record entry in `record_entries` must have the following structure:

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `name` | `string` | - | Yes | Record name (RR) | - |
| `type` | `string` | - | Yes | Record type | Must be one of: `A`, `CNAME`, `TXT`, `MX`, `PTR`, `SRV` |
| `value` | `string` | - | Yes | Record value | - |
| `ttl` | `number` | `60` | No | Time to live in seconds | - |
| `lang` | `string` | `"en"` | No | Language | Must be `"zh"` or `"en"` |
| `priority` | `number` | `1` | No | Priority (for MX records) | Must be 1-99 |
| `remark` | `string` | `""` | No | Record remark | Max 50 characters, only Chinese, English, numbers, '.', '_' or '-' |
| `status` | `string` | `"ENABLE"` | No | Record status | Must be `"ENABLE"` or `"DISABLE"` |

### VPC Binding Object Structure

Each VPC binding in `vpc_bindings` must have the following structure:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `vpc_id` | `string` | Yes | The VPC ID to bind |
| `region_id` | `string` | No | The region ID. If not set, the current region will be used |

## Outputs

| Name | Description |
|------|-------------|
| `zone_id` | Application Private Zone ID |
| `zone_record_ids` | Application Private Zone record ID list |

## Examples

### Basic Usage

```hcl
module "private_zone" {
  source = "./modules/private-zone"

  zone_name   = "internal.example.com"
  zone_remark = "Internal DNS zone"
  
  vpc_bindings = [
    {
      vpc_id    = "vpc-abc123"
      region_id = "cn-hangzhou"
    }
  ]
  
  record_entries = [
    {
      name  = "www"
      type  = "A"
      value = "10.0.1.10"
    },
    {
      name  = "api"
      type  = "A"
      value = "10.0.1.20"
    }
  ]
}
```

### With MX Record

```hcl
module "private_zone" {
  source = "./modules/private-zone"

  zone_name = "mail.example.com"
  
  vpc_bindings = [
    {
      vpc_id = "vpc-abc123"
    }
  ]
  
  record_entries = [
    {
      name     = "@"
      type     = "MX"
      value    = "mail.example.com"
      priority = 10
      ttl      = 300
    }
  ]
}
```

### Multi-VPC Binding

```hcl
module "private_zone" {
  source = "./modules/private-zone"

  zone_name = "shared.example.com"
  
  vpc_bindings = [
    {
      vpc_id    = "vpc-hangzhou"
      region_id = "cn-hangzhou"
    },
    {
      vpc_id    = "vpc-shanghai"
      region_id = "cn-shanghai"
    }
  ]
  
  record_entries = []
}
```

## Notes

- VPC bindings can span multiple regions
- Record entries support multiple DNS record types with appropriate validation

