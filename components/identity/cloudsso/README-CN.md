<div align="right">

**中文** | [English](README.md)

</div>

# CloudSSO 组件

该组件用于创建和管理阿里云 CloudSSO（云单点登录）目录、访问配置、用户、组和访问分配，实现集中式身份和访问管理。

## 功能特性

- 创建 CloudSSO 目录，支持配置名称和随机后缀
- 创建访问配置，支持系统托管策略或内联自定义策略
- 创建 CloudSSO 用户和组
- 配置用户/组到成员账号和主账号的访问分配
- 支持从文件（JSON/YAML）加载配置或内联定义
- 配置登录偏好、MFA 设置和密码策略
- 如果 IAM 账号与主账号不同，自动委派 IAM 账号

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |
| random | >= 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |
| alicloud.master | >= 1.267.0 |
| alicloud.iam | >= 1.267.0 |
| random | >= 3.6.0 |

## Modules

| Name | Source | Description |
|------|--------|-------------|
| users_and_groups | ../../../modules/cloudsso-users-and-groups | CloudSSO 用户和组 |

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_account.master](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | 主账号信息 |
| [alicloud_account.iam](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | IAM 账号信息 |
| [alicloud_cloud_sso_service.enable](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/cloud_sso_service) | data source | CloudSSO 服务开通 |
| [alicloud_resource_manager_accounts.accounts](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/resource_manager_accounts) | data source | 资源目录账号查询 |
| [random_string.directory_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource | 目录名称的随机后缀（可选） |
| [alicloud_cloud_sso_directory.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_sso_directory) | resource | CloudSSO 目录 |
| [alicloud_cloud_sso_delegate_account.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_sso_delegate_account) | resource | 委派账号（当 IAM 账号与主账号不同时） |
| [alicloud_cloud_sso_access_configuration.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_sso_access_configuration) | resource | 访问配置 |
| [alicloud_cloud_sso_access_assignment.member_accounts](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_sso_access_assignment) | resource | 成员账号的访问分配 |
| [alicloud_cloud_sso_access_assignment.master_account](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_sso_access_assignment) | resource | 主账号的访问分配 |

## 使用方法

```hcl
module "cloudsso" {
  source = "./components/identity/cloudsso"

  providers = {
    alicloud.master = alicloud.master
    alicloud.iam    = alicloud.iam
  }

  directory_name = "my-cloudsso"
  
  access_configurations = [
    {
      name        = "Administrator"
      description = "完全访问配置"
      managed_system_policies = ["AliyunFullAccess"]
      session_duration = 3600
    }
  ]
  
  users = [
    {
      user_name = "admin"
      email     = "admin@example.com"
      status    = "Enabled"
    }
  ]
  
  access_assignments = [
    {
      principal_name             = "admin"
      principal_type             = "User"
      account_names              = ["account-1", "account-2"]
      include_master_account     = true
      access_configuration_names = ["Administrator"]
    }
  ]
}
```

## 输入参数

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `directory_name` | CloudSSO 目录名称 | `string` | `null` | No | 如果为 null，则从账号 ID 生成。2-64 个字符，小写字母/数字/连字符，不能以连字符开头或结尾，不能以 'd-' 开头 |
| `append_random_suffix` | 是否在目录名称后追加随机后缀 | `bool` | `false` | No | - |
| `random_suffix_length` | 随机后缀长度 | `number` | `6` | No | 3-16 |
| `random_suffix_separator` | 目录名称和后缀之间的分隔符 | `string` | `"-"` | No | 必须是：`"-"`、`"_"` 或 `""` |
| `login_preference` | CloudSSO 目录的登录偏好 | `object` | `null` | No | 参见登录偏好结构 |
| `mfa_authentication_setting_info` | 全局 MFA 验证配置 | `object` | `null` | No | 参见 MFA 结构 |
| `password_policy` | 密码策略配置 | `object` | `null` | No | 参见密码策略结构 |
| `access_configurations` | 要创建的访问配置列表 | `list(object)` | `[]` | No | 参见访问配置结构 |
| `access_configurations_dir` | 包含访问配置文件的目录路径 | `string` | `null` | No | JSON/YAML 文件，与 `access_configurations` 合并 |
| `users` | 要创建的 CloudSSO 用户列表 | `list(object)` | `[]` | No | 参见用户结构 |
| `groups` | 要创建的 CloudSSO 组列表 | `list(object)` | `[]` | No | 参见组结构 |
| `access_assignments` | 访问分配列表 | `list(object)` | `[]` | No | 参见访问分配结构 |

### 登录偏好对象结构

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `allow_user_to_get_credentials` | `bool` | `false` | No | 允许用户获取凭证 |
| `login_network_masks` | `string` | `null` | No | 登录网络掩码（CIDR） |

### MFA 认证设置信息对象结构

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `mfa_authentication_advance_settings` | `string` | `"Enabled"` | No | MFA 高级设置 | 必须是：`Enabled`、`ByUser`、`Disabled`、`OnlyRiskyLogin` |
| `operation_for_risk_login` | `string` | `null` | No | 风险登录操作 | 必须是：`Autonomous` 或 `EnforceVerify` |

### 密码策略对象结构

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `max_login_attempts` | `number` | `5` | No | 最大登录尝试次数 | 0-32（0 = 无限制） |
| `max_password_age` | `number` | `90` | No | 最大密码有效期（天） | 1-120 |
| `min_password_different_chars` | `number` | `4` | No | 最小不同字符数 | 0 到 min_password_length |
| `min_password_length` | `number` | `8` | No | 最小密码长度 | 8-32 |
| `password_not_contain_username` | `bool` | `true` | No | 密码不能包含用户名 | - |
| `password_reuse_prevention` | `number` | `1` | No | 密码重用防护 | 0-24（0 = 禁用） |

### 访问配置对象结构

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `name` | `string` | - | Yes | 访问配置名称 | 1-32 个字符，字母/数字/连字符 |
| `description` | `string` | `null` | No | 描述 | 提供时 1-1024 个字符 |
| `relay_state` | `string` | `"https://home.console.aliyun.com/"` | No | 中继状态 URL | - |
| `session_duration` | `number` | `3600` | No | 会话时长（秒） | 900-43200 |
| `managed_system_policies` | `list(string)` | `[]` | No | 系统托管策略名称 | - |
| `inline_custom_policy` | `object` | `null` | No | 内联自定义策略 | 参见内联策略结构 |

### 内联自定义策略对象结构

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `policy_name` | `string` | `"InlinePolicy"` | No | 策略名称 |
| `policy_document` | `string` | - | Yes | 策略文档（JSON 字符串） |

### 用户对象结构

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `user_name` | `string` | - | Yes | 用户名 |
| `display_name` | `string` | `null` | No | 显示名称 |
| `description` | `string` | `null` | No | 描述 |
| `email` | `string` | `null` | No | 邮箱地址 |
| `first_name` | `string` | `null` | No | 名 |
| `last_name` | `string` | `null` | No | 姓 |
| `password` | `string` | `null` | No | 密码 |
| `mfa_authentication_settings` | `string` | `"Enabled"` | No | MFA 设置 |
| `status` | `string` | `"Enabled"` | No | 用户状态 |
| `tags` | `map(string)` | `{}` | No | 标签 |

### 组对象结构

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `group_name` | `string` | - | Yes | 组名称 |
| `description` | `string` | `null` | No | 描述 |
| `user_names` | `list(string)` | `[]` | No | 组中的用户名列表 |

### 访问分配对象结构

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `principal_name` | `string` | - | Yes | 用户或组名称 | - |
| `principal_type` | `string` | `"User"` | No | 主体类型 | 必须是：`User` 或 `Group` |
| `account_names` | `list(string)` | `[]` | No | 成员账号显示名称 | - |
| `include_master_account` | `bool` | `false` | No | 包含主账号 | - |
| `access_configuration_names` | `list(string)` | - | Yes | 访问配置名称 | 至少需要一个 |

## 输出参数

| Name | Description |
|------|-------------|
| `directory_id` | CloudSSO 目录 ID |
| `directory_name` | CloudSSO 目录名称 |
| `access_configurations` | 访问配置及其名称和 ID 的列表 |
| `users` | 创建的 CloudSSO 用户信息 |
| `groups` | 创建的 CloudSSO 组信息 |
| `access_assignments` | 访问分配 ID 列表 |

## 使用示例

### 基础 CloudSSO 配置

```hcl
module "cloudsso" {
  source = "./components/identity/cloudsso"

  providers = {
    alicloud.master = alicloud.master
    alicloud.iam    = alicloud.iam
  }

  directory_name = "enterprise-sso"
  
  access_configurations = [
    {
      name        = "Administrator"
      managed_system_policies = ["AliyunFullAccess"]
    }
  ]
}
```

### CloudSSO 配置用户和访问分配

```hcl
module "cloudsso" {
  source = "./components/identity/cloudsso"

  providers = {
    alicloud.master = alicloud.master
    alicloud.iam    = alicloud.iam
  }

  directory_name = "enterprise-sso"
  
  access_configurations = [
    {
      name        = "ReadOnly"
      managed_system_policies = ["AliyunReadOnlyAccess"]
    }
  ]
  
  users = [
    {
      user_name = "admin"
      email     = "admin@example.com"
    },
    {
      user_name = "developer"
      email     = "dev@example.com"
    }
  ]
  
  groups = [
    {
      group_name = "Developers"
      user_names = ["developer"]
    }
  ]
  
  access_assignments = [
    {
      principal_name             = "admin"
      principal_type             = "User"
      account_names              = ["account-1"]
      access_configuration_names = ["ReadOnly"]
    },
    {
      principal_name             = "Developers"
      principal_type             = "Group"
      account_names              = ["account-1", "account-2"]
      access_configuration_names = ["ReadOnly"]
    }
  ]
}
```

### CloudSSO 配置自定义策略

```hcl
module "cloudsso" {
  source = "./components/identity/cloudsso"

  providers = {
    alicloud.master = alicloud.master
    alicloud.iam    = alicloud.iam
  }

  directory_name = "enterprise-sso"
  
  access_configurations = [
    {
      name        = "CustomPolicy"
      description = "自定义访问配置"
      inline_custom_policy = {
        policy_name = "CustomInlinePolicy"
        policy_document = jsonencode({
          Version = "1"
          Statement = [
            {
              Effect   = "Allow"
              Action   = ["oss:GetObject", "oss:ListObjects"]
              Resource = "*"
            }
          ]
        })
      }
    }
  ]
}
```

## 注意事项

- 创建目录前会自动开通 CloudSSO 服务
- 如果未指定目录名称，默认为 `CloudSSO-{account_id}`
- 可以追加随机后缀以确保全局唯一性
- 如果 IAM 账号与主账号不同，会自动委派 IAM 账号
- 访问配置支持系统托管策略和内联自定义策略
- 访问分配中的账号名称通过资源目录解析为 ID
- 文件配置优先于内联配置（同名时）
- 用户和组使用 cloudsso-users-and-groups 模块创建

