<div align="right">

**中文** | [English](README.md)

</div>

# Tag Policy 模块

该模块用于创建和管理阿里云标签策略及其绑定关系,以控制资源的标签行为。

## 功能特性

- 创建自定义规则的标签策略
- 将标签策略绑定到用户、账号或资源目录
- 支持多个策略绑定
- 强化标签合规性和治理

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
| [alicloud_tag_policy.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/tag_policy) | resource | 标签策略 |
| [alicloud_tag_policy_attachment.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/tag_policy_attachment) | resource | 标签策略绑定 |

## 使用方法

```hcl
module "tag_policy" {
  source = "./modules/tag-policy"

  tag_policies = [
    {
      policy_name = "EnforceEnvironmentTag"
      policy_desc = "在所有资源上强制使用 Environment 标签"
      policy_content = jsonencode({
        tags = {
          Environment = {
            tag_key = {
              "@@assign" = "Environment"
            }
            tag_value = {
              "@@assign" = ["production", "staging", "development"]
            }
          }
        }
      })
      user_type = "ACCOUNT"
    }
  ]

  policy_attachments = [
    {
      policy_name = "EnforceEnvironmentTag"
      target_id   = "<ACCOUNT_ID>"
      target_type = "ACCOUNT"
    }
  ]
}
```

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `tag_policies` | 要创建的标签策略列表 | `list(object)` | `[]` | 否 | 见下方标签策略结构 |
| `policy_attachments` | 要创建的策略绑定列表 | `list(object)` | `[]` | 否 | 见下方策略绑定结构 |

### 标签策略对象结构

`tag_policies` 中每个标签策略的结构如下:

| 字段 | 类型 | 必填 | 说明 | 限制条件 |
|------|------|------|------|----------|
| `policy_name` | `string` | 是 | 标签策略名称 | 1-128 个字符,不能以 "http://" 或 "https://" 开头 |
| `policy_desc` | `string` | 否 | 标签策略描述 | 1-512 个字符,不能以 "http://" 或 "https://" 开头 |
| `policy_content` | `string` | 是 | JSON 格式的标签策略内容 | 有效的 JSON 字符串,定义标签规则 |
| `user_type` | `string` | 否 | 用户类型 | 有效值: USER, ACCOUNT, RD。默认值: USER |

### 策略绑定对象结构

`policy_attachments` 中每个策略绑定的结构如下:

| 字段 | 类型 | 必填 | 说明 | 限制条件 |
|------|------|------|------|----------|
| `policy_name` | `string` | 是 | 要绑定的标签策略名称 | 必须匹配 tag_policies 中的策略名称 |
| `target_id` | `string` | 是 | 要绑定策略的目标 ID | 有效的用户 ID、账号 ID 或资源目录 ID |
| `target_type` | `string` | 是 | 目标类型 | 有效值: USER, ACCOUNT, RD |

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `policy_ids` | 策略名称到其 ID 的映射 |
| `policy_names` | 已创建的标签策略名称列表 |
| `attachment_ids` | 策略绑定 ID 列表 |

## 使用示例

### 基础标签策略

```hcl
module "tag_policy" {
  source = "./modules/tag-policy"

  tag_policies = [
    {
      policy_name = "RequireProjectTag"
      policy_desc = "要求资源必须有 Project 标签"
      policy_content = jsonencode({
        tags = {
          Project = {
            tag_key = {
              "@@assign" = "Project"
            }
            tag_value = {
              "@@assign" = ["*"]
            }
            enforced_for = {
              "@@assign" = ["*"]
            }
          }
        }
      })
    }
  ]
}
```

### 带多个绑定的标签策略

```hcl
module "tag_policy" {
  source = "./modules/tag-policy"

  tag_policies = [
    {
      policy_name = "TagGovernance"
      policy_desc = "综合标签治理策略"
      policy_content = jsonencode({
        tags = {
          Environment = {
            tag_key = {
              "@@assign" = "Environment"
            }
            tag_value = {
              "@@assign" = ["production", "staging", "development"]
            }
          }
          CostCenter = {
            tag_key = {
              "@@assign" = "CostCenter"
            }
            tag_value = {
              "@@assign" = ["*"]
            }
          }
        }
      })
      user_type = "ACCOUNT"
    }
  ]

  policy_attachments = [
    {
      policy_name = "TagGovernance"
      target_id   = "<ACCOUNT_ID>"
      target_type = "ACCOUNT"
    },
    {
      policy_name = "TagGovernance"
      target_id   = "rd-abcdef****"
      target_type = "RD"
    }
  ]
}
```

### 限制标签值

```hcl
module "tag_policy" {
  source = "./modules/tag-policy"

  tag_policies = [
    {
      policy_name = "RestrictEnvironmentValues"
      policy_desc = "限制 Environment 标签只能使用特定值"
      policy_content = jsonencode({
        tags = {
          Environment = {
            tag_key = {
              "@@assign" = "Environment"
            }
            tag_value = {
              "@@assign" = ["production", "staging"]
            }
          }
        }
      })
    }
  ]

  policy_attachments = [
    {
      policy_name = "RestrictEnvironmentValues"
      target_id   = "<ACCOUNT_ID>"
      target_type = "ACCOUNT"
    }
  ]
}
```

## 注意事项

- 标签策略有助于在资源间强制执行一致的标签
- 策略内容必须是符合阿里云标签策略架构的有效 JSON
- **重要**: 每个标签键都必须包含 `tag_value` 字段。使用 `["*"]` 表示允许任意值
- `@@assign` 操作符用于定义标签规则
- `enforced_for` 字段是可选的，用于事前拦截（阻止创建不符合规范的资源）
  - 不要在 `enforced_for` 中使用 `["*"]` - 不支持此格式
  - 请指定具体的资源类型，如 `ACS::ECS::Instance`、`ACS::RDS::DBInstance` 等
  - 省略 `enforced_for` 以仅使用事后检测（大多数情况下推荐）
- 标签策略可以绑定到用户、账号或资源目录
- 同一个目标可以绑定多个策略
- 策略绑定需要先创建策略 (模块会自动处理)
- USER 类型用于单个 RAM 用户
- ACCOUNT 类型用于阿里云账号
- RD 类型用于资源目录 (多账号管理)
