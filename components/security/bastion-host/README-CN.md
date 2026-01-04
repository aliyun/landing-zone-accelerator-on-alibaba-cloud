<div align="right">

**中文** | [English](README.md)

</div>

# Bastion Host 组件

该组件用于创建和管理阿里云堡垒机实例，提供安全的服务器访问能力。

## 功能特性

- 创建堡垒机实例
- 可选创建 VPC、交换机和安全组资源
- 配置 SSH 和 HTTPS 访问规则
- 创建堡垒机服务关联角色
- 支持使用现有 VPC 资源

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| alicloud | ~> 1.262.1 |

## Providers

| Name | Version |
|------|---------|
| alicloud | ~> 1.262.1 |

## Modules

| Name | Source | Description |
|------|--------|-------------|
| slr-with-service-name | terraform-alicloud-modules/service-linked-role/alicloud | 堡垒机服务关联角色 |

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_account.current](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | 当前账号信息 |
| [alicloud_vpc.bastion_vpc](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpc) | resource | 堡垒机 VPC（可选） |
| [alicloud_vswitch.bastion_vswitch](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource | 堡垒机交换机（可选） |
| [alicloud_security_group.bastion_sg](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group) | resource | 堡垒机安全组（可选） |
| [alicloud_security_group_rule.allow_ssh](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group_rule) | resource | SSH 访问规则（可选） |
| [alicloud_security_group_rule.allow_https](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group_rule) | resource | HTTPS 访问规则（可选） |
| [alicloud_bastionhost_instance.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/bastionhost_instance) | resource | 堡垒机实例 |
| [null_resource.wait_for_service_init](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource | 等待服务初始化 |

## 使用方法

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  create_bastion_host = true
  
  bastion_host_description = "生产环境堡垒机"
  bastion_host_license_code = "bhah_ent_50_asset"
  bastion_host_plan_code = "cloudbastion"
  bastion_host_storage = "5"
  bastion_host_bandwidth = "5"
  bastion_host_period = 1
  
  create_vpc_resources = true
  vpc_cidr = "192.168.0.0/16"
  vswitch_cidr = "192.168.1.0/24"
  availability_zone = "cn-hangzhou-h"
}
```

## 输入参数

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `create_bastion_host` | 是否创建堡垒机实例 | `bool` | `false` | No | - |
| `bastion_host_description` | 堡垒机实例描述 | `string` | `""` | No | - |
| `bastion_host_license_code` | 堡垒机实例许可证代码 | `string` | `"bhah_ent_50_asset"` | No | - |
| `bastion_host_plan_code` | 堡垒机实例套餐代码 | `string` | `"cloudbastion"` | No | - |
| `bastion_host_storage` | 堡垒机实例存储容量 | `string` | `"5"` | No | - |
| `bastion_host_bandwidth` | 堡垒机实例带宽 | `string` | `"5"` | No | - |
| `bastion_host_period` | 堡垒机实例购买时长（月） | `number` | `1` | No | - |
| `create_vpc_resources` | 是否创建 VPC 资源 | `bool` | `false` | No | - |
| `vpc_cidr` | VPC CIDR 网段 | `string` | `"192.168.0.0/16"` | No | - |
| `vswitch_cidr` | 交换机 CIDR 网段 | `string` | `"192.168.1.0/24"` | No | - |
| `availability_zone` | 交换机可用区 | `string` | `""` | No | 当 `create_vpc_resources = true` 时必需 |
| `vpc_name` | VPC 名称 | `string` | `"bastion-host-vpc"` | No | - |
| `vswitch_name` | 交换机名称 | `string` | `"bastion-host-vswitch"` | No | - |
| `security_group_name` | 安全组名称 | `string` | `"bastion-host-sg"` | No | - |
| `bastion_host_vswitch_id` | 现有交换机的 ID | `string` | `""` | No | 当 `create_vpc_resources = false` 时必需 |
| `bastion_host_security_group_ids` | 现有安全组的 ID 列表 | `list(string)` | `[]` | No | 当 `create_vpc_resources = false` 时必需 |
| `bastion_host_tags` | 堡垒机实例标签 | `map(string)` | `{Environment = "landingzone", Project = "terraform-alicloud-landing-zone-accelerator"}` | No | - |
| `ssh_rule_cidr_ip` | SSH 规则的 CIDR IP | `string` | `"0.0.0.0/0"` | No | - |
| `https_rule_cidr_ip` | HTTPS 规则的 CIDR IP | `string` | `"0.0.0.0/0"` | No | - |

## 输出参数

| Name | Description |
|------|-------------|
| `bastion_host_instance_id` | 堡垒机实例 ID |
| `bastion_host_vpc_id` | 堡垒机 VPC ID |
| `bastion_host_vswitch_id` | 堡垒机交换机 ID |
| `bastion_host_security_group_id` | 堡垒机安全组 ID |
| `service_linked_role_names` | 服务关联角色名称 |

## 使用示例

### 创建堡垒机并创建 VPC 资源

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  create_bastion_host = true
  create_vpc_resources = true
  
  vpc_cidr = "10.0.0.0/16"
  vswitch_cidr = "10.0.1.0/24"
  availability_zone = "cn-hangzhou-h"
  
  bastion_host_tags = {
    Environment = "production"
    Team        = "security"
  }
}
```

### 使用现有 VPC 资源

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  create_bastion_host = true
  create_vpc_resources = false
  
  bastion_host_vswitch_id = "vsw-abc123"
  bastion_host_security_group_ids = ["sg-xyz789"]
}
```

## 注意事项

- 堡垒机服务需要服务关联角色，组件会自动创建
- 创建 VPC 资源时，组件会等待 60 秒以确保服务初始化完成
- SSH 和 HTTPS 规则配置允许从指定 CIDR 网段访问
- 存储和带宽值决定实例规格
- 购买时长单位为月（最少 1 个月）

