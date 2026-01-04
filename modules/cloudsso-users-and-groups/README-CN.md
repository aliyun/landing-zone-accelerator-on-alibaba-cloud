<div align="right">

**中文** | [English](README.md)

</div>

# CloudSSO Users and Groups 模块

该模块用于创建和管理阿里云 CloudSSO 用户和组，包括用户-组关联关系。

## 功能特性

- 创建 CloudSSO 用户，支持全面配置
- 创建 CloudSSO 组
- 关联用户与组
- 支持用户认证设置（MFA、状态）

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
| [alicloud_cloud_sso_user.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_sso_user) | resource | CloudSSO 用户 |
| [alicloud_cloud_sso_group.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_sso_group) | resource | CloudSSO 组 |
| [alicloud_cloud_sso_user_attachment.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_sso_user_attachment) | resource | 用户-组关联 |

## 使用方法

```hcl
module "cloudsso_users_groups" {
  source = "./modules/cloudsso-users-and-groups"

  directory_id = "d-1234567890abcdef0"
  
  users = [
    {
      user_name = "john.doe"
      display_name = "John Doe"
      email = "john.doe@example.com"
      status = "Enabled"
    }
  ]
  
  groups = [
    {
      group_name = "developers"
      description = "Development team"
      user_names = ["john.doe"]
    }
  ]
}
```

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `directory_id` | CloudSSO 目录 ID | `string` | - | 是 | 必须匹配格式：`d-[A-Za-z0-9]+` |
| `users` | CloudSSO 用户列表 | `list(object)` | `[]` | 否 | 见下方用户对象结构 |
| `groups` | CloudSSO 组列表 | `list(object)` | `[]` | 否 | 见下方组对象结构 |

### 用户对象结构

`users` 中每个用户对象的结构如下：

| 字段 | 类型 | 默认值 | 必填 | 说明 | 限制条件 |
|------|------|--------|------|------|----------|
| `user_name` | `string` | - | 是 | 用户名 | 1-64 个字符，只能包含数字、字母和 @_-. 字符 |
| `display_name` | `string` | `null` | 否 | 显示名称 | 最大 256 个字符 |
| `description` | `string` | `null` | 否 | 用户描述 | 最大 1024 个字符 |
| `email` | `string` | `null` | 否 | 邮箱地址 | 有效邮箱格式，最大 128 个字符 |
| `first_name` | `string` | `null` | 否 | 名 | 最大 64 个字符 |
| `last_name` | `string` | `null` | 否 | 姓 | 最大 64 个字符 |
| `password` | `string` | `null` | 否 | 用户密码 | 8-32 个字符，必须包含大写字母、小写字母、数字和特殊字符 |
| `mfa_authentication_settings` | `string` | `"Enabled"` | 否 | MFA 认证设置 | 必须为 `"Enabled"` 或 `"Disabled"` |
| `status` | `string` | `"Enabled"` | 否 | 用户状态 | 必须为 `"Enabled"` 或 `"Disabled"` |
| `tags` | `map(string)` | `{}` | 否 | 用户标签 | - |

### 组对象结构

`groups` 中每个组对象的结构如下：

| 字段 | 类型 | 默认值 | 必填 | 说明 | 限制条件 |
|------|------|--------|------|------|----------|
| `group_name` | `string` | - | 是 | 组名 | 1-128 个字符，只能包含字母、数字和 _-. 字符 |
| `description` | `string` | `null` | 否 | 组描述 | 最大 1024 个字符 |
| `user_names` | `list(string)` | `[]` | 否 | 要添加到组的用户名列表 | 用户名必须存在于 `users` 中 |

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `user_ids` | 用户 ID 列表 |
| `users` | 用户名到用户信息的映射（user_id, user_name, status） |
| `group_ids` | 组 ID 列表 |
| `groups` | 组名到组信息的映射（group_id, group_name） |
| `user_attachment_ids` | 用户关联的资源 ID，格式：`<directory_id>:<group_id>:<user_id>` |

## 使用示例

### 仅创建用户

```hcl
module "cloudsso_users_groups" {
  source = "./modules/cloudsso-users-and-groups"

  directory_id = "d-1234567890abcdef0"
  
  users = [
    {
      user_name  = "alice.smith"
      display_name = "Alice Smith"
      email      = "alice.smith@example.com"
      first_name = "Alice"
      last_name  = "Smith"
      status     = "Enabled"
    },
    {
      user_name  = "bob.jones"
      display_name = "Bob Jones"
      email      = "bob.jones@example.com"
      status     = "Enabled"
    }
  ]
}
```

### 创建组并关联用户

```hcl
module "cloudsso_users_groups" {
  source = "./modules/cloudsso-users-and-groups"

  directory_id = "d-1234567890abcdef0"
  
  users = [
    {
      user_name = "admin.user"
      email     = "admin@example.com"
      status    = "Enabled"
    },
    {
      user_name = "dev.user"
      email     = "dev@example.com"
      status    = "Enabled"
    }
  ]
  
  groups = [
    {
      group_name  = "administrators"
      description = "System administrators"
      user_names  = ["admin.user"]
    },
    {
      group_name  = "developers"
      description = "Development team"
      user_names  = ["dev.user"]
    }
  ]
}
```

### 禁用 MFA 的用户

```hcl
module "cloudsso_users_groups" {
  source = "./modules/cloudsso-users-and-groups"

  directory_id = "d-1234567890abcdef0"
  
  users = [
    {
      user_name                 = "service.account"
      email                     = "service@example.com"
      mfa_authentication_settings = "Disabled"
      status                    = "Enabled"
    }
  ]
}
```

## 注意事项

- 用户密码必须满足复杂度要求：8-32 个字符，包含大写字母、小写字母、数字和特殊字符
- 密码在生命周期变更中被忽略，以防止意外更新
- `groups[].user_names` 中引用的用户名必须存在于 `users` 列表中
- 默认情况下，所有用户都启用 MFA 认证
- 可以通过将 `status` 设置为 `"Disabled"` 来禁用用户

