<div align="right">

**中文** | [English](README.md)

</div>

# Bastion Host 组件

该组件用于创建和管理阿里云堡垒机实例，提供安全的服务器访问能力。

## 功能特性

- 自动创建堡垒机服务关联角色（SLR）`AliyunServiceRoleForBastionhost`
- 创建堡垒机实例
- 导入 ECS 实例到堡垒机
- 创建堡垒机资产组
- 创建和管理主机账户
- 配置主机与资产组的关联（支持一个主机属于多个资产组）
- 支持配置多个 AD 认证服务器
- 支持配置多个 LDAP 认证服务器
- 支持使用现有堡垒机实例（通过 existing_bastionhost_instance_id
- 支持使用现有主机（通过 existing_host_id）
- 支持使用现有资产组（通过 host_group_name）

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | ~> 1.267.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | ~> 1.267.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| bastion-host-slr | terraform-alicloud-modules/service-linked-role/alicloud | 1.2.0 |

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [module.bastion-host-slr](https://registry.terraform.io/modules/terraform-alicloud-modules/service-linked-role/alicloud/latest) | module | 堡垒机服务关联角色 |
| [alicloud_bastionhost_instance.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/bastionhost_instance) | resource | 堡垒机实例 |
| [alicloud_bastionhost_host.hosts](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/bastionhost_host) | resource | 堡垒机主机 |
| [alicloud_bastionhost_host_group.groups](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/bastionhost_host_group) | resource | 堡垒机资产组 |
| [alicloud_bastionhost_host_account.accounts](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/bastionhost_host_account) | resource | 堡垒机主机账户 |
| [alicloud_bastionhost_host_attachment.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/bastionhost_host_attachment) | resource | 堡垒机主机与资产组的关联 |


## 使用方法

### 基础配置

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  # 服务关联角色配置（可选，默认为 true）
  create_bastion_host_slr = true  # 创建 AliyunServiceRoleForBastionhost
  
  create_bastion_host = true
  
  bastionhost_description = "生产环境堡垒机"
  bastionhost_license_code = "bhah_ent_50_asset"
  bastionhost_plan_code = "cloudbastion"
  bastionhost_storage = 5
  bastionhost_bandwidth = 5
  bastionhost_period = 1
  bastionhost_vswitch_id = "vsw-xxxxxxxxxxxx"
  bastionhost_security_group_ids = ["sg-xxxxxxxxxxxx"]
  bastionhost_slave_vswitch_id = "vsw-xxxxxxxxxxxx"

  bastionhost_host_groups = [{
    host_group_name = "group_test"
    comment         = "Test Bastion Host Group"
  }]

  # 主机配置方式见下方
}
```

### 主机配置方式

#### 方法一：直接配置

在 Terraform 代码中直接使用 `bastionhost_hosts` 参数配置主机：

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  # ... 其他配置 ...

  bastionhost_hosts = [
    {
      host_config = {
        active_address_type  = "Private"
        comment              = "Test Bastion Host"
        host_name            = "web-server-1"
        host_private_address = "192.168.0.27"
        os_type              = "Linux"
        source               = "Ecs"
        source_instance_id   = "i-xxxxxxxxxxxx"
      }
      host_group_names = ["group_test"]
      host_accounts = [
        {
          protocol_name     = "SSH"
          host_account_name = "account1"
          password          = "your-password"
        }
      ]
    },
    {
      existing_host_id  = "xx"
      host_group_names  = ["group_test"]
      host_accounts = [
        {
          protocol_name     = "SSH"
          host_account_name = "account1"
          password          = "your-password"
        }
      ]
    }
  ]
}
```

#### 方法二：从文件加载

使用 `host_file_paths` 或 `host_dir_paths` 参数从 YAML/JSON 文件加载主机配置：

**方式 2.1：从单个或多个文件加载**

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  # ... 其他配置 ...

  host_file_paths = [
    "./configs/hosts_production.json",
    "./configs/hosts_staging.yaml"
  ]
}
```

**方式 2.2：从目录加载**

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  # ... 其他配置 ...

  host_dir_paths = [
    "./configs/hosts/"
  ]
}
```

**方式 2.3：混合使用**

可以同时使用直接配置和文件加载，配置会被合并：

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  # ... 其他配置 ...

  # 直接配置的主机
  bastionhost_hosts = [
    {
      host_config = {
        active_address_type  = "Private"
        host_private_address = "192.168.1.10"
        os_type              = "Linux"
        source               = "Ecs"
        source_instance_id   = "i-abc123"
      }
      host_group_names = ["direct-config"]
    }
  ]

  # 从文件加载的主机
  host_file_paths = ["./configs/hosts.json"]
  host_dir_paths  = ["./configs/hosts/"]
}
```

**文件格式说明：**

文件必须是包含主机对象数组的 YAML 或 JSON 格式。

**JSON 格式示例（hosts.json）：**

```json
[
  {
    "existing_host_id": null,
    "host_config": {
      "active_address_type": "Private",
      "comment": "Test Bastion Host",
      "host_name": "web-server-1",
      "host_private_address": "192.168.0.27",
      "host_public_address": null,
      "instance_region_id": "cn-shanghai",
      "os_type": "Linux",
      "source": "Ecs",
      "source_instance_id": "i-xxxxxxxxxxxx"
    },
    "host_group_names": ["group_test"],
    "host_accounts": [
      {
        "protocol_name": "SSH",
        "host_account_name": "account1",
        "password": "your-password"
      }
    ]
  }
]
```

**YAML 格式示例（hosts.yaml）：**

```yaml
- existing_host_id: null
  host_config:
    active_address_type: "Private"
    comment: "Test Bastion Host"
    host_name: "web-server-1"
    host_private_address: "192.168.0.27"
    host_public_address: null
    instance_region_id: "cn-shanghai"
    os_type: "Linux"
    source: "Ecs"
    source_instance_id: "i-xxxxxxxxxxxx"
  host_group_names:
    - "group_test"
  host_accounts:
    - protocol_name: "SSH"
      host_account_name: "account1"
      password: "your-password"
```

## 输入参数

### 基础配置

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `create_bastion_host_slr` | 是否创建堡垒机服务关联角色。启用时会自动创建 `AliyunServiceRoleForBastionhost` 角色 | `bool` | `true` | No |
| `create_bastion_host` | 是否创建堡垒机实例 | `bool` | `true` | No |
| `existing_bastionhost_instance_id` | 现有堡垒机实例 ID | `string` | `null` | No |

### 堡垒机实例配置

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `bastionhost_description` | 堡垒机实例描述 | `string` | `null` | Yes* | 1-63 字符，当 `create_bastion_host=true` 时必填 |
| `bastionhost_license_code` | 许可证代码 | `string` | `null` | Yes* | 必须匹配格式 `bhah_ent_xxx_asset`（xxx 可为任意值），当 `create_bastionhost_host=true` 时必填 |
| `bastionhost_plan_code` | 套餐代码 | `string` | `null` | Yes* | `cloudbastion` 或 `cloudbastion_ha`，当 `create_bastion_host=true` 时必填 |
| `bastionhost_storage` | 存储容量（GB） | `number` | `null` | Yes* | 0-500，当 `create_bastion_host=true` 时必填 |
| `bastionhost_bandwidth` | 带宽（Mbps） | `number` | `null` | Yes* | 0-150，必须是 5 的倍数，当 `create_bastion_host=true` 时必填 |
| `bastionhost_period` | 购买时长（月） | `number` | `null` | No | 1-9, 12, 24, 36 |
| `bastionhost_vswitch_id` | 主交换机 ID | `string` | `null` | Yes* | 当 `create_bastion_host=true` 时必填 |
| `bastionhost_slave_vswitch_id` | 备交换机 ID（HA 模式） | `string` | `null` | No | 仅当 `bastionhost_plan_code="cloudbastion_ha"` 时可设置 |
| `bastionhost_security_group_ids` | 安全组 ID 列表 | `set(string)` | `[]` | Yes* | 当 `create_bastion_host=true` 时必填，至少包含一个安全组 ID |
| `bastionhost_tags` | 标签 | `map(string)` | `null` | No | - |
| `bastionhost_resource_group_id` | 资源组 ID | `string` | `null` | No | - |
| `bastionhost_enable_public_access` | 是否启用公网访问 | `bool` | `null` | No | - |
| `bastionhost_ad_auth_server` | AD 认证服务器配置列表 | `list(object)` | `null` | No | 见下方详细说明 |
| `bastionhost_ldap_auth_server` | LDAP 认证服务器配置列表 | `list(object)` | `null` | No | 见下方详细说明 |
| `bastionhost_renew_period` | 续费时长 | `number` | `null` | No | 1-9, 12, 24, 36，当`renewal_status="AutoRenewal"` 时必填 |
| `bastionhost_renewal_status` | 续费状态 | `string` | `null` | No | `AutoRenewal`, `ManualRenewal`, `NotRenewal` |
| `bastionhost_renewal_period_unit` | 续费周期单位 | `string` | `null` | No | `M` 或 `Y` |
| `bastionhost_public_white_list` | 公网白名单 IP 列表 | `list(string)` | `[]` | No | - |

**bastionhost_ad_auth_server 对象结构：**

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `account` | 账户 | `string` | Yes |
| `base_dn` | Base DN | `string` | Yes |
| `domain` | 域名 | `string` | Yes |
| `email_mapping` | 邮箱映射 | `string` | No |
| `filter` | 过滤器 | `string` | No |
| `is_ssl` | 是否使用 SSL | `bool` | Yes |
| `mobile_mapping` | 手机映射 | `string` | No |
| `name_mapping` | 名称映射 | `string` | No |
| `password` | 密码 | `string` | No |
| `port` | 端口 | `number` | Yes |
| `server` | 服务器地址 | `string` | Yes |
| `standby_server` | 备用服务器地址 | `string` | No |

**bastionhost_ldap_auth_server 对象结构：**

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `account` | 账户 | `string` | Yes |
| `base_dn` | Base DN | `string` | Yes |
| `email_mapping` | 邮箱映射 | `string` | No |
| `filter` | 过滤器 | `string` | No |
| `is_ssl` | 是否使用 SSL | `bool` | No |
| `login_name_mapping` | 登录名映射 | `string` | No |
| `mobile_mapping` | 手机映射 | `string` | No |
| `name_mapping` | 名称映射 | `string` | No |
| `password` | 密码 | `string` | No |
| `port` | 端口 | `number` | Yes |
| `server` | 服务器地址 | `string` | Yes |
| `standby_server` | 备用服务器地址 | `string` | No |

### 资产组配置

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `bastionhost_host_groups` | 资产组配置列表 | `list(object)` | `[]` | No |

**bastionhost_host_groups 对象结构：**

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `host_group_name` | 资产组名称 | `string` | Yes |
| `comment` | 备注 | `string` | No |

### 主机配置

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `bastionhost_hosts` | 主机配置列表 | `list(object)` | `[]` | No | 见下方详细说明 |
| `host_file_paths` | 主机配置文件路径列表（YAML/JSON） | `list(string)` | `[]` | No | 文件必须包含主机对象数组 |
| `host_dir_paths` | 主机配置目录路径列表（YAML/JSON） | `list(string)` | `[]` | No | 目录中的文件将被加载，文件必须包含主机对象数组 |

**bastionhost_hosts 对象结构：**

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `existing_host_id` | 现有主机 ID | `string` | `null`| No | 与 `host_config` 二选一，必须提供其中一个 |
| `host_config` | 主机配置对象 | `object` | `null` | No | 见下方详细说明（与 `existing_host_id` 二选一） |
| `host_group_names` | 资产组名称列表 | `list(string)` | `[]` | No | 一个主机可以属于多个资产组 |
| `host_accounts` | 主机账户列表 | `list(object)` | `[]` | No | 见下方详细说明 |

**host_config 对象结构：**

| Name | Description | Type | Required | Constraints |
|------|-------------|------|----------|-------------|
| `active_address_type` | 活动地址类型 | `string` | Yes | `Public` 或 `Private` |
| `comment` | 备注 | `string` | No | 1-500 字符 |
| `host_name` | 主机名称 | `string` | No | 1-128 字符 |
| `host_private_address` | 主机私网地址 | `string` | Yes* | 当 `active_address_type="Private"` 时必填 |
| `host_public_address` | 主机公网地址 | `string` | No | - |
| `instance_region_id` | 实例地域 ID | `string` | No | - |
| `os_type` | 操作系统类型 | `string` | Yes | `Linux` 或 `Windows` |
| `source` | 来源 | `string` | Yes | `Local`, `Ecs`, `Rds` |
| `source_instance_id` | 源实例 ID（ECS ID） | `string` | Yes* | 当 `source="Ecs"` 或 `source="Rds"` 时必填 |

**host_accounts 对象结构：**

| Name | Description | Type | Required | Constraints |
|------|-------------|------|----------|-------------|
| `host_account_name` | 账户名称 | `string` | Yes | 1-128 字符 |
| `pass_phrase` | 密码短语（SSH 协议） | `string` | No | - |
| `password` | 密码 | `string` | No | - |
| `private_key` | 私钥（SSH 协议） | `string` | No | - |
| `protocol_name` | 协议名称 | `string` | Yes | `SSH` 或 `RDP` |



## 输出参数

| Name | Description |
|------|-------------|
| `bastionhost_instance_id` | 堡垒机实例 ID |
| `bastionhost_instance_info` | 堡垒机实例信息 |
| `bastionhost_host_group_maps` | 堡垒机资产组（Map 格式，以 host_group_name 为键） |
| `bastionhost_hosts_list` | 堡垒机主机列表 |
| `bastionhost_host_accounts_list` | 堡垒机资产账户列表（包含密码信息）|

## 使用示例

### 创建堡垒机并启用
```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  create_bastion_host = true
  
  bastionhost_description = "生产环境堡垒机"
  bastionhost_license_code = "bhah_ent_50_asset"
  bastionhost_plan_code = "cloudbastion_ha"
  bastionhost_storage = 5
  bastionhost_bandwidth = 5
  bastionhost_period = 1

  bastionhost_vswitch_id = "vsw-xxxxxxxxxxxx"
  bastionhost_security_group_ids = ["sg-xxxxxxxxxxxx"]
  bastionhost_slave_vswitch_id = "vsw-xxxxxxxxxxxx"
}
```

### 导入主机并创建主机账户

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  create_bastion_host = true
  # ... 其他配置 ...
  
  bastionhost_host_groups = [
    {
      host_group_name = "web-servers"
      comment         = "Web服务器组"
    }
  ]

  bastionhost_hosts = [
    {
      host_config = {
        active_address_type  = "Private"
        host_private_address = "192.168.1.10"
        os_type             = "Linux"
        source              = "Ecs"
        source_instance_id  = "i-xxxxxxxxxxxx"
        host_name           = "web-server-1"
      }
      host_accounts = [
        {
          host_account_name = "root"
          protocol_name     = "SSH"
          password          = "your-password"
        }
      ]
      host_group_names = ["web-servers"]
    }
  ]
}
```

### 使用现有堡垒机实例

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  create_bastion_host = false
  existing_bastionhost_instance_id = "bastionhost-cn-hangzhou-abc123"
  
  bastionhost_hosts = [
    {
      existing_host_id    = "host-xyz789"
      host_group_names    = ["existing-group"]
    }
  ]
}
```

### 配置 AD/LDAP 认证服务器

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  create_bastion_host = true
  # ... 其他配置 ...
  
  bastionhost_ad_auth_server = [
    {
      server         = "192.168.1.1"
      standby_server = "192.168.1.3"
      port           = 389
      domain         = "example.com"
      account        = "cn=Manager,dc=example,dc=com"
      password       = "your-password"
      filter         = "objectClass=person"
      name_mapping   = "nameAttr"
      email_mapping  = "emailAttr"
      mobile_mapping = "mobileAttr"
      is_ssl         = false
      base_dn        = "dc=example,dc=com"
    }
  ]
  
  bastionhost_ldap_auth_server = [
    {
      server             = "192.168.1.1"
      standby_server     = "192.168.1.3"
      port               = 389
      login_name_mapping = "uid"
      account            = "cn=Manager,dc=example,dc=com"
      password           = "your-password"
      filter             = "objectClass=person"
      name_mapping       = "nameAttr"
      email_mapping      = "emailAttr"
      mobile_mapping     = "mobileAttr"
      is_ssl             = false
      base_dn            = "dc=example,dc=com"
    }
  ]
}
```

## 注意事项

- **服务关联角色（SLR）**：默认情况下，此组件会自动创建堡垒机服务所需的服务关联角色 `AliyunServiceRoleForBastionhost`。您可以通过 `create_bastion_host_slr` 变量控制此行为（默认为 `true`）。SLR 会在堡垒机实例创建之前创建，以确保服务正确初始化。
- 主机配置中，如果 `existing_host_id` 不为空，则使用现有主机；否则需要在 `host_config` 中提供主机配置信息
- `host_group_names` 是列表类型，一个主机可以属于多个资产组
- 支持通过 `host_file_paths` 和 `host_dir_paths` 从文件或目录加载主机配置（YAML/JSON 格式），文件内容必须是主机对象数组
- 主机账户的 `protocol_name` 为 `SSH` 时，可以使用 `private_key` 或 `pass_phrase`；为 `RDP` 时，使用 `password`
- AD 和 LDAP 认证服务器支持配置多个，使用列表格式
- 许可证代码支持 `bhah_ent_xxx_asset` 格式，其中 `xxx` 支持 50\100\200\500\1000\2000\5000\10000
- 存储和带宽值决定实例规格
- 购买时长单位为月（1-9, 12, 24, 36）
- 当 `create_bastion_host=true` 时，以下参数为必填：`bastionhost_description`、`bastionhost_license_code`、`bastionhost_plan_code`、`bastionhost_storage`、`bastionhost_bandwidth`、`bastionhost_vswitch_id`、`bastionhost_security_group_ids`（至少包含一个安全组 ID）
- 当 `bastionhost_plan_code="cloudbastion_ha"` 时，可以设置 `bastionhost_slave_vswitch_id`；其他情况下 `bastionhost_slave_vswitch_id` 必须为 `null`
- 堡垒机需要指定`bastionhost_vswitch_id`以及`bastionhost_security_group_ids`后才能启用
