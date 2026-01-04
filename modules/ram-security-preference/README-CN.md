<div align="right">

**中文** | [English](README.md)

</div>

# RAM Security Preference 模块

该模块用于配置阿里云 RAM 安全偏好设置和密码策略，以增强账户安全性。

## 功能特性

- 配置 RAM 密码策略（复杂度、有效期、重用防护）
- 配置 RAM 安全偏好设置（MFA、会话时长、登录限制）
- 管理用户密码和 MFA 设备管理权限
- 配置登录网络掩码以实现基于 IP 的访问控制

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| alicloud | >= 1.262.1 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.262.1 |

## Modules

无模块。

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_ram_password_policy.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ram_password_policy) | resource | RAM 密码策略 |
| [alicloud_ram_security_preference.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ram_security_preference) | resource | RAM 安全偏好设置 |

## 使用方法

```hcl
module "ram_security_preference" {
  source = "./modules/ram-security-preference"

  allow_user_to_change_password = true
  allow_user_to_manage_mfa_devices = true
  
  login_session_duration = 8
  
  password_policy = {
    minimum_password_length = 12
    require_lowercase_characters = true
    require_numbers = true
    require_uppercase_characters = true
    require_symbols = true
    max_password_age = 90
  }
}
```

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `allow_user_to_change_password` | 允许用户更改密码 | `bool` | `true` | 否 | - |
| `allow_user_to_login_with_passkey` | 是否允许 RAM 用户使用通行密钥登录 | `bool` | `true` | 否 | - |
| `allow_user_to_manage_access_keys` | 是否允许 RAM 用户管理自己的访问密钥 | `bool` | `false` | 否 | - |
| `allow_user_to_manage_mfa_devices` | 是否允许 RAM 用户管理 MFA 设备 | `bool` | `true` | 否 | - |
| `allow_user_to_manage_personal_ding_talk` | 是否允许 RAM 用户管理个人钉钉绑定 | `bool` | `true` | 否 | - |
| `enable_save_mfa_ticket` | 是否保存 MFA 验证状态（有效期 7 天） | `bool` | `true` | 否 | - |
| `login_session_duration` | 登录会话时长（小时） | `number` | `6` | 否 | 必须为 1-24 |
| `login_network_masks` | 允许登录的 IP 地址范围列表 | `list(string)` | `[]` | 否 | 最多 40 个掩码 |
| `mfa_operation_for_login` | 登录时的 MFA 要求 | `string` | `"independent"` | 否 | 必须为：`mandatory`、`independent`、`adaptive` |
| `operation_for_risk_login` | 异常登录时的 MFA 验证 | `string` | `"autonomous"` | 否 | 必须为：`autonomous`、`enforceVerify` |
| `verification_types` | 多因素认证方式 | `set(string)` | `[]` | 否 | 必须为：`sms`、`email`，或为空 |
| `password_policy` | RAM 密码策略配置 | `object` | 见下方 | 否 | 见下方密码策略结构 |

### 密码策略对象结构

`password_policy` 对象的结构如下：

| 字段 | 类型 | 默认值 | 必填 | 说明 |
|------|------|--------|------|------|
| `minimum_password_length` | `number` | `8` | 否 | 最小密码长度 |
| `require_lowercase_characters` | `bool` | `true` | 否 | 需要小写字母 |
| `require_numbers` | `bool` | `true` | 否 | 需要数字 |
| `require_uppercase_characters` | `bool` | `true` | 否 | 需要大写字母 |
| `require_symbols` | `bool` | `false` | 否 | 需要符号 |
| `max_password_age` | `number` | `90` | 否 | 最大密码有效期（天） |
| `password_reuse_prevention` | `number` | `3` | 否 | 防止重用的历史密码数量 |
| `max_login_attempts` | `number` | `5` | 否 | 锁定前的最大登录尝试次数 |
| `hard_expiry` | `bool` | `false` | 否 | 密码硬过期 |
| `password_not_contain_user_name` | `bool` | `false` | 否 | 密码不能包含用户名 |
| `minimum_password_different_character` | `number` | `0` | 否 | 与之前密码的最小不同字符数 |

## 输出参数

该模块不提供任何输出。

## 使用示例

### 基础安全偏好设置

```hcl
module "ram_security_preference" {
  source = "./modules/ram-security-preference"
}
```

### 增强安全配置

```hcl
module "ram_security_preference" {
  source = "./modules/ram-security-preference"

  allow_user_to_change_password = true
  allow_user_to_manage_access_keys = false
  allow_user_to_manage_mfa_devices = true
  
  login_session_duration = 4
  login_network_masks = ["192.168.1.0/24", "10.0.0.0/8"]
  
  mfa_operation_for_login = "mandatory"
  operation_for_risk_login = "enforceVerify"
  verification_types = ["sms", "email"]
  
  password_policy = {
    minimum_password_length = 16
    require_lowercase_characters = true
    require_numbers = true
    require_uppercase_characters = true
    require_symbols = true
    max_password_age = 60
    password_reuse_prevention = 5
    max_login_attempts = 3
    hard_expiry = false
    password_not_contain_user_name = true
    minimum_password_different_character = 4
  }
}
```

### 自适应 MFA 配置

```hcl
module "ram_security_preference" {
  source = "./modules/ram-security-preference"

  mfa_operation_for_login = "adaptive"
  operation_for_risk_login = "enforceVerify"
  enable_save_mfa_ticket = true
  
  password_policy = {
    minimum_password_length = 12
    require_symbols = true
    max_password_age = 90
  }
}
```

## 注意事项

- 密码策略适用于账户中的所有 RAM 用户
- 安全偏好设置是账户级别的设置
- `mfa_operation_for_login` 选项：
  - `mandatory`：所有 RAM 用户必须使用 MFA
  - `independent`：取决于个人用户配置
  - `adaptive`：仅在异常登录时使用
- `login_network_masks` 限制登录到指定的 IP 范围（空列表允许所有）
- `verification_types` 可以包含 `sms` 和/或 `email` 用于 MFA
- 会话时长以小时为单位（1-24）
- 密码重用防护防止使用最近 N 个密码

