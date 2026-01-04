<div align="right">

**中文** | [English](README.md)

</div>

# RAM Role 模块

该模块用于创建和管理阿里云 RAM（资源访问管理）角色，并附加策略。

## 功能特性

- 创建带自定义信任策略的 RAM 角色
- 绑定已有系统策略
- 绑定已有自定义策略
- 创建并绑定自定义策略
- 支持 MFA 要求配置
- 配置会话时长

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

| Name | Source | Version |
|------|--------|---------|
| ram_role | terraform-alicloud-modules/ram-role/alicloud | 2.0.0 |

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_ram_policy.policy](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ram_policy) | resource | 内联自定义 RAM 策略 |

## 使用方法

```hcl
module "ram_role" {
  source = "./modules/ram-role"

  role_name        = "my-role"
  role_description = "My RAM role"
  
  trusted_services = ["ecs.aliyuncs.com"]
  
  managed_system_policy_names = ["AliyunECSReadOnlyAccess"]
  
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
| `role_name` | RAM 角色名称 | `string` | - | 是 | - |
| `role_description` | RAM 角色描述 | `string` | `null` | 否 | - |
| `force` | 是否强制删除 RAM 策略 | `bool` | `true` | 否 | - |
| `max_session_duration` | 最大会话时长（秒） | `number` | `3600` | 否 | - |
| `role_requires_mfa` | 角色是否需要 MFA | `bool` | `true` | 否 | - |
| `trusted_principal_arns` | 可以承担此角色的阿里云实体 ARN | `list(string)` | `[]` | 否 | 与 `trust_policy` 冲突 |
| `trusted_services` | 可以承担此角色的阿里云服务 | `list(string)` | `[]` | 否 | 与 `trust_policy` 冲突 |
| `trust_policy` | 自定义角色信任策略 | `string` | `null` | 否 | 与 `trusted_principal_arns` 和 `trusted_services` 冲突 |
| `managed_system_policy_names` | 要附加的系统类型托管策略名称列表 | `list(string)` | `[]` | 否 | - |
| `attach_admin_policy` | 是否附加管理员策略 | `bool` | `false` | 否 | - |
| `attach_readonly_policy` | 是否附加只读策略 | `bool` | `false` | 否 | - |
| `managed_custom_policy_names` | 要附加的自定义类型托管策略名称列表 | `list(string)` | `[]` | 否 | - |
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
| `role_name` | RAM 角色名称 |
| `role_arn` | RAM 角色 ARN |
| `role_id` | RAM 角色 ID |

## 使用示例

### 带服务信任的基础 RAM 角色

```hcl
module "ram_role" {
  source = "./modules/ram-role"

  role_name        = "ecs-role"
  role_description = "Role for ECS service"
  
  trusted_services = ["ecs.aliyuncs.com"]
}
```

### 带系统策略的 RAM 角色

```hcl
module "ram_role" {
  source = "./modules/ram-role"

  role_name        = "readonly-role"
  role_description = "Read-only access role"
  
  trusted_services = ["ecs.aliyuncs.com"]
  
  attach_readonly_policy = true
  managed_system_policy_names = ["AliyunOSSReadOnlyAccess"]
}
```

### 带自定义信任策略的 RAM 角色

```hcl
module "ram_role" {
  source = "./modules/ram-role"

  role_name        = "cross-account-role"
  role_description = "Role for cross-account access"
  
  trust_policy = jsonencode({
    Version = "1"
    Statement = [{
      Effect = "Allow"
      Principal = {
        RAM = ["acs:ram::1234567890123456:root"]
      }
      Action = "sts:AssumeRole"
    }]
  })
}
```

### 带内联自定义策略的 RAM 角色

```hcl
module "ram_role" {
  source = "./modules/ram-role"

  role_name        = "custom-policy-role"
  role_description = "Role with custom policies"
  
  trusted_services = ["ecs.aliyuncs.com"]
  
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

## 注意事项

- `trusted_principal_arns`、`trusted_services` 和 `trust_policy` 只能指定其中一个
- 按名称引用的已有自定义策略必须在创建角色之前存在
- `attach_admin_policy` 和 `attach_readonly_policy` 是常见用例的便捷标志
- 默认启用 MFA 要求（`role_requires_mfa = true`）
- 最大会话时长默认为 3600 秒（1 小时）

