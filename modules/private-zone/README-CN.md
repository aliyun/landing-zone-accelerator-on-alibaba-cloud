<div align="right">

**中文** | [English](README.md)

</div>

# Private Zone 模块

该模块用于创建和管理阿里云私有 DNS 解析服务（Private DNS Zone）资源，包括解析域创建、VPC 绑定和 DNS 记录管理。

## 功能特性

- 创建私有 DNS 解析域，支持配置代理模式
- 将解析域绑定到多个 VPC（支持跨地域）
- 管理 DNS 记录（A、CNAME、TXT、MX、PTR、SRV 类型）
- 自动开通 Private Zone 服务

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |

## Modules

无模块。

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_pvtz_service.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/pvtz_service) | data source | Private Zone 服务开通 |
| [alicloud_pvtz_zone.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/pvtz_zone) | resource | 私有 DNS 解析域 |
| [alicloud_pvtz_zone_attachment.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/pvtz_zone_attachment) | resource | 解析域的 VPC 绑定 |
| [alicloud_pvtz_zone_record.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/pvtz_zone_record) | resource | 解析域内的 DNS 记录 |

## 使用方法

```hcl
module "private_zone" {
  source = "./modules/private-zone"

  zone_name     = "example.com"
  zone_remark   = "示例私有解析域"
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

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `zone_name` | 私有 DNS 解析域名称 | `string` | - | 是 | - |
| `zone_remark` | 私有 DNS 解析域备注 | `string` | `null` | 否 | 最大 50 个字符，仅支持中文、英文、数字、'.'、'_' 或 '-' |
| `proxy_pattern` | 递归 DNS 代理模式 | `string` | `"ZONE"` | 否 | 必须为 `"ZONE"` 或 `"RECORD"` |
| `lang` | 解析域语言 | `string` | `"en"` | 否 | 必须为 `"zh"` 或 `"en"` |
| `resource_group_id` | 解析域所属的资源组 ID | `string` | `""` | 否 | - |
| `tags` | 解析域的标签 | `map(string)` | `{}` | 否 | - |
| `vpc_bindings` | VPC 绑定列表，定义解析域生效范围 | `list(object)` | `[]` | 否 | 每个对象包含 `vpc_id`（必填）和 `region_id`（可选） |
| `record_entries` | DNS 记录配置 | `list(object)` | `[]` | 否 | 见下方记录对象结构说明 |

### 记录对象结构

`record_entries` 中每个记录对象的结构如下：

| 字段 | 类型 | 默认值 | 必填 | 说明 | 限制条件 |
|------|------|--------|------|------|----------|
| `name` | `string` | - | 是 | 记录名称（RR） | - |
| `type` | `string` | - | 是 | 记录类型 | 必须为：`A`、`CNAME`、`TXT`、`MX`、`PTR`、`SRV` 之一 |
| `value` | `string` | - | 是 | 记录值 | - |
| `ttl` | `number` | `60` | 否 | 生存时间（秒） | - |
| `lang` | `string` | `"en"` | 否 | 语言 | 必须为 `"zh"` 或 `"en"` |
| `priority` | `number` | `1` | 否 | 优先级（MX 记录使用） | 必须为 1-99 |
| `remark` | `string` | `""` | 否 | 记录备注 | 最大 50 个字符，仅支持中文、英文、数字、'.'、'_' 或 '-' |
| `status` | `string` | `"ENABLE"` | 否 | 记录状态 | 必须为 `"ENABLE"` 或 `"DISABLE"` |

### VPC 绑定对象结构

`vpc_bindings` 中每个 VPC 绑定对象的结构如下：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `vpc_id` | `string` | 是 | 要绑定的 VPC ID |
| `region_id` | `string` | 否 | 地域 ID。如果不设置，将使用当前地域 |

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `zone_id` | 私有 DNS 解析域 ID |
| `zone_record_ids` | 私有 DNS 解析域记录 ID 列表 |

## 使用示例

### 基础用法

```hcl
module "private_zone" {
  source = "./modules/private-zone"

  zone_name   = "internal.example.com"
  zone_remark = "内部 DNS 解析域"
  
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

### 包含 MX 记录

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

### 多 VPC 绑定

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

## 注意事项

- VPC 绑定支持跨地域
- 记录条目支持多种 DNS 记录类型，并包含相应的验证规则

