<div align="right">

**中文** | [English](README.md)

</div>

# 共享带宽包模块

该模块用于创建和管理阿里云共享带宽包（Common Bandwidth Package），用于多个 EIP 实例共享带宽。

## 功能特性

- 创建共享带宽包
- 将多个 EIP 实例关联到共享带宽包
- 支持为每个 EIP 关联配置带宽限制
- 支持多种计费方式（PayByBandwidth、PayBy95、PayByDominantTraffic）
- 支持删除保护和强制删除

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_common_bandwidth_package.bandwidth_package](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/common_bandwidth_package) | resource | 共享带宽包 |
| [alicloud_common_bandwidth_package_attachment.bandwidth_package_attachment](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/common_bandwidth_package_attachment) | resource | EIP 到带宽包的关联 |

## 使用方法

### 基础共享带宽包

```hcl
module "common_bandwidth_package" {
  source = "./modules/common-bandwidth-package"

  bandwidth_package_name = "shared-bandwidth"
  bandwidth              = "100"
  eip_attachments = [
    {
      instance_id = "eip-2ze0xxxxxxxxxxxxxxxx"
    },
    {
      instance_id = "eip-2ze0xxxxxxxxxxxxxxxx"
    }
  ]
}
```

### 带 EIP 带宽限制的共享带宽包

```hcl
module "common_bandwidth_package" {
  source = "./modules/common-bandwidth-package"

  bandwidth_package_name = "shared-bandwidth"
  bandwidth              = "200"
  internet_charge_type   = "PayByBandwidth"
  eip_attachments = [
    {
      instance_id              = "eip-2ze0xxxxxxxxxxxxxxxx"
      bandwidth_package_bandwidth = "50"
    },
    {
      instance_id              = "eip-2ze0xxxxxxxxxxxxxxxx"
      bandwidth_package_bandwidth = "100"
    }
  ]
}
```

### PayBy95 计费的共享带宽包

```hcl
module "common_bandwidth_package" {
  source = "./modules/common-bandwidth-package"

  bandwidth_package_name     = "shared-bandwidth-payby95"
  bandwidth                  = "500"
  internet_charge_type       = "PayBy95"
  ratio                      = 20
  security_protection_types  = ["AntiDDoS_Enhanced"]
  eip_attachments = [
    {
      instance_id = "eip-2ze0xxxxxxxxxxxxxxxx"
    },
    {
      instance_id = "eip-2ze0xxxxxxxxxxxxxxxx"
    },
    {
      instance_id = "eip-2ze0xxxxxxxxxxxxxxxx"
    }
  ]
}
```

### 与 EIP 模块配合使用

```hcl
module "eip" {
  source = "./modules/eip"

  eip_instances = [
    {
      payment_type     = "PayAsYouGo"
      eip_address_name = "eip-1"
    },
    {
      payment_type     = "PayAsYouGo"
      eip_address_name = "eip-2"
    }
  ]
}

module "common_bandwidth_package" {
  source = "./modules/common-bandwidth-package"

  bandwidth_package_name = "shared-bandwidth"
  bandwidth              = "200"
  eip_attachments = [
    for eip in module.eip.eip_instances : {
      instance_id              = eip.id
      bandwidth_package_bandwidth = eip.id == module.eip.eip_instances[0].id ? "50" : "100"
    }
  ]
}
```

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `bandwidth` | 共享带宽包带宽（Mbps） | `string` | `"5"` | 否 | 1-1000 之间的整数 |
| `internet_charge_type` | 共享带宽包计费方式 | `string` | `"PayByBandwidth"` | 否 | 必须为：`PayByBandwidth`、`PayBy95`、`PayByDominantTraffic` |
| `bandwidth_package_name` | 共享带宽包名称 | `string` | `null` | 否 | 2-256 个字符，以字母开头，不能以 http:// 或 https:// 开头 |
| `ratio` | PayBy95 计费方式的比率 | `number` | `20` | 否 | 必须为 20 |
| `deletion_protection` | 是否启用删除保护 | `bool` | `false` | 否 | - |
| `description` | 共享带宽实例的描述 | `string` | `null` | 否 | 0-256 个字符，不能以 http:// 或 https:// 开头 |
| `force` | 是否强制删除共享带宽实例 | `bool` | `false` | 否 | - |
| `isp` | 共享带宽包的线路类型 | `string` | `"BGP"` | 否 | 必须为：`BGP` 或 `BGP_PRO` |
| `resource_group_id` | 资源组 ID | `string` | `null` | 否 | - |
| `security_protection_types` | 抗 DDoS 版本 | `list(string)` | `[]` | 否 | 空列表表示基础版，`AntiDDoS_Enhanced` 表示增强版。仅在 internet_charge_type 为 PayBy95 时有效。最多 10 个元素 |
| `tags` | 共享带宽包资源的标签 | `map(string)` | `{}` | 否 | - |
| `zone` | 共享带宽实例的可用区 | `string` | `null` | 否 | 为云盒创建时必须 |
| `eip_attachments` | EIP 关联到共享带宽包的列表 | `list(object)` | `[]` | 否 | 每个对象包含 instance_id 和可选的 bandwidth_package_bandwidth。bandwidth_package_bandwidth 可以是正整数字符串或 `"Cancelled"`（从版本 1.261.0 开始） |

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `bandwidth_package_id` | 共享带宽包 ID |
| `bandwidth_package_name` | 共享带宽包名称 |
| `attachment_ids` | EIP 关联到带宽包的关联 ID 列表 |
| `attachment_details` | 关联详情列表，包含关联 ID、EIP 实例 ID 和 bandwidth_package_bandwidth |

## 注意事项

- 共享带宽包允许多个 EIP 共享带宽，降低成本
- `PayBy95` 计费方式需要 `ratio = 20`
- `security_protection_types` 仅在 `internet_charge_type` 为 `PayBy95` 时有效，最多支持 10 个安全防护级别
- `zone` 为云盒创建共享带宽实例时必须
- `force` 设置为 `true` 时，将强制解绑所有 EIP 并删除带宽包
- `eip_attachments` 中的 `bandwidth_package_bandwidth` 字段设置每个 EIP 关联到带宽包时的最大带宽。该值不能超过共享带宽实例的最大带宽。从版本 1.261.0 开始，设置为 `"Cancelled"` 将取消 EIP 的最大带宽配置
- 如果关联对象中未提供 `bandwidth_package_bandwidth`，EIP 关联将不设置带宽限制

