<div align="right">

**中文** | [English](README.md)

</div>

# RAM User 模块

该模块用于创建和管理阿里云 RAM（资源访问管理）用户，并附加策略、配置登录配置文件和访问密钥。

## 功能特性

- 创建带可选显示信息的 RAM 用户
- 绑定已有系统策略
- 绑定已有自定义策略
- 创建并绑定自定义策略
- 配置登录配置文件（密码和 MFA 设置）
- 创建访问密钥（支持可选 PGP 加密）
- 支持强制销毁以进行清理

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |

## Providers

| Name | Version |
|------|--------|
| alicloud | >= 1.267.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| ram_user | terraform-alicloud-modules/ram-user/alicloud | 1.0.0 |

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_ram_policy.policy](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ram_policy) | resource | 内联自定义 RAM 策略 |

## 使用方法

```hcl
module "ram_user" {
  source = "./components/account-factory/baseline/ram-user"

  user_name    = "my-user"
  display_name = "My User"
  email        = "user@example.com"
  mobile       = "86-18600008888"
  comments     = "Test user"
  
  create_ram_user_login_profile = true
  password                      = "SecurePassword123!"
  password_reset_required       = true
  mfa_bind_required            = true
  
  create_ram_access_key = true
  pgp_key              = "keybase:username"
  
  managed_system_policy_names = ["AliyunOSSReadOnlyAccess"]
  
  inline_custom_policies = [
    {
      policy_name     = "custom-policy"
      policy_document = jsonencode({
        Version = "1"
        Statement = [{
          Effect   = "Allow"
          Action   = ["oss:GetObject"]
          Resource = ["acs:oss:*:*:my-bucket/*"]
        }]
      })
      description = "Custom policy for OSS access"
    }
  ]
}
```

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `user_name` | RAM 用户名称。 | `string` | - | 是 | 必须为 1-64 个字符，只能包含英文字母、数字、半角句号（.）、短划线（-）和下划线（_） |
| `display_name` | RAM 用户的显示名称 | `string` | `null` | 否 | - |
| `mobile` | RAM 用户的手机号码。此号码必须包含国际区号前缀，格式如：86-18600008888。 | `string` | `null` | 否 | - |
| `email` | RAM 用户的邮箱 | `string` | `null` | 否 | - |
| `comments` | RAM 用户的备注。此参数可以是 1 到 128 个字符的字符串。 | `string` | `null` | 否 | - |
| `force_destroy_user` | 销毁此用户时，即使它有非 Terraform 管理的 RAM 访问密钥、登录配置文件或 MFA 设备，也要销毁。 | `bool` | `false` | 否 | - |
| `create_ram_user_login_profile` | 是否创建 RAM 用户登录配置文件 | `bool` | `false` | 否 | - |
| `password` | 用户的登录密码 | `string` | `null` | 否 | 敏感 |
| `password_reset_required` | 此参数指示用户登录时是否需要重置密码。 | `bool` | `null` | 否 | - |
| `mfa_bind_required` | 此参数指示用户登录时是否需要绑定 MFA。 | `bool` | `null` | 否 | - |
| `create_ram_access_key` | 是否创建 RAM 访问密钥。默认值为 'false'。 | `bool` | `false` | 否 | - |
| `pgp_key` | base-64 编码的 PGP 公钥，或 keybase 用户名 | `string` | `null` | 否 | - |
| `secret_file` | 用于存储用户访问密钥和密钥的文件。 | `string` | `null` | 否 | - |
| `status` | 访问密钥的状态 | `string` | `"Active"` | 否 | - |
| `managed_custom_policy_names` | 要附加到 RAM 用户的自定义类型托管策略名称列表 | `list(string)` | `[]` | 否 | - |
| `managed_system_policy_names` | 要附加到 RAM 用户的系统类型托管策略名称列表 | `list(string)` | `[]` | 否 | - |
| `inline_custom_policies` | 要创建并附加的自定义策略列表 | `list(object)` | `[]` | 否 | 见下方内联策略结构 |

### 内联自定义策略对象结构

`inline_custom_policies` 中每个内联自定义策略的结构如下：

| 字段 | 类型 | 默认值 | 必填 | 说明 |
|------|------|--------|------|------|
| `policy_name` | `string` | - | 是 | 策略名称 |
| `policy_document` | `string` | - | 是 | JSON 格式的策略文档 |
| `description` | `string` | `null` | 否 | 策略描述 |
| `force` | `bool` | `true` | 否 | 是否强制删除策略 |

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `user_name` | RAM 用户名称 |
| `user_id` | 阿里云分配的唯一 ID |
| `access_key_id` | 访问密钥 ID |
| `access_key_secret` | 访问密钥密钥（敏感） |
| `access_key_encrypted_secret` | 访问密钥加密密钥，base64 编码 |
| `access_key_key_fingerprint` | 用于加密密钥的 PGP 密钥指纹 |
| `access_key_status` | Active 或 Inactive。密钥最初是活动的，但可以通过其他方式变为非活动。 |
| `pgp_key` | 用于加密此用户敏感数据的 PGP 密钥（如果为空，则不加密） |

## 使用示例

### 基础 RAM 用户

```hcl
module "ram_user" {
  source = "./components/account-factory/baseline/ram-user"

  user_name    = "basic-user"
  display_name = "Basic User"
  email        = "basic@example.com"
}
```

### 带登录配置文件的 RAM 用户

```hcl
module "ram_user" {
  source = "./components/account-factory/baseline/ram-user"

  user_name                    = "login-user"
  display_name                 = "Login User"
  email                        = "login@example.com"
  create_ram_user_login_profile = true
  password                     = "SecurePassword123!"
  password_reset_required      = true
  mfa_bind_required           = true
}
```

### 带访问密钥的 RAM 用户

```hcl
module "ram_user" {
  source = "./components/account-factory/baseline/ram-user"

  user_name           = "access-key-user"
  display_name        = "Access Key User"
  email               = "accesskey@example.com"
  create_ram_access_key = true
  pgp_key             = "keybase:username"
}
```

### 带系统策略的 RAM 用户

```hcl
module "ram_user" {
  source = "./components/account-factory/baseline/ram-user"

  user_name                   = "policy-user"
  display_name                = "Policy User"
  email                       = "policy@example.com"
  managed_system_policy_names = [
    "AliyunOSSReadOnlyAccess",
    "AliyunECSReadOnlyAccess"
  ]
}
```

### 带内联自定义策略的 RAM 用户

```hcl
module "ram_user" {
  source = "./components/account-factory/baseline/ram-user"

  user_name    = "custom-policy-user"
  display_name = "Custom Policy User"
  email        = "custom@example.com"
  
  inline_custom_policies = [
    {
      policy_name     = "oss-access"
      policy_document = jsonencode({
        Version = "1"
        Statement = [{
          Effect   = "Allow"
          Action   = ["oss:GetObject", "oss:PutObject"]
          Resource = ["acs:oss:*:*:my-bucket/*"]
        }]
      })
      description = "OSS bucket access policy"
    }
  ]
}
```

### 完整 RAM 用户示例

```hcl
module "ram_user" {
  source = "./components/account-factory/baseline/ram-user"

  user_name    = "complete-user"
  display_name = "Complete User"
  email        = "complete@example.com"
  mobile       = "86-18600008888"
  comments     = "Complete user example"
  
  force_destroy_user = true
  
  create_ram_user_login_profile = true
  password                       = "SecurePassword123!"
  password_reset_required        = true
  mfa_bind_required             = true
  
  create_ram_access_key = true
  pgp_key              = "keybase:username"
  secret_file          = "./secrets/access_key.txt"
  status               = "Active"
  
  managed_system_policy_names = ["AliyunOSSReadOnlyAccess"]
  managed_custom_policy_names = ["existing-custom-policy"]
  
  inline_custom_policies = [
    {
      policy_name     = "custom-oss-policy"
      policy_document = jsonencode({
        Version = "1"
        Statement = [{
          Effect   = "Allow"
          Action   = ["oss:GetObject"]
          Resource = ["acs:oss:*:*:my-bucket/*"]
        }]
      })
      description = "Custom OSS access policy"
    }
  ]
}
```

## 注意事项

- `password` 变量被标记为敏感，不会在日志中显示
- 当提供 `pgp_key` 时，访问密钥密钥将使用 PGP 加密
- `force_destroy_user` 应谨慎使用，因为它会删除用户，即使它有非 Terraform 管理的资源
- 按名称引用的已有自定义策略必须在创建用户之前存在
- 手机号码必须包含国际区号前缀（例如："86-18600008888"）
- 当 `create_ram_access_key` 为 `true` 且未提供 `pgp_key` 时，密钥将以明文形式存储（请谨慎使用）
