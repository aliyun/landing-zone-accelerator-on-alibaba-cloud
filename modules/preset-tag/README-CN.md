<div align="right">

**中文** | [English](README.md)

</div>

# Preset Tag 模块

该模块用于创建和管理阿里云预设标签（元标签），可在多个资源中使用。

## 功能特性

- 创建带键和值的预设标签
- 支持每个标签键有多个值

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
| [alicloud_tag_meta_tag.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/tag_meta_tag) | resource | 预设标签（元标签） |

## 使用方法

```hcl
module "preset_tag" {
  source = "./modules/preset-tag"

  preset_tags = [
    {
      key    = "Environment"
      values = ["production", "staging", "development"]
    },
    {
      key    = "Project"
      values = ["landing-zone"]
    }
  ]
}
```

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `preset_tags` | 要创建的预设标签列表 | `list(object)` | `[]` | 否 | 见下方预设标签结构 |

### 预设标签对象结构

`preset_tags` 中每个预设标签的结构如下：

| 字段 | 类型 | 必填 | 说明 | 限制条件 |
|------|------|------|------|----------|
| `key` | `string` | 是 | 标签键 | 1-128 个字符，不能以 "aliyun" 或 "acs:" 开头，不能包含 "http://" 或 "https://" |
| `values` | `list(string)` | 是 | 标签值列表 | 1-10 个值，每个值最多 128 个字符，不能包含 "http://" 或 "https://" |

## 输出参数

该模块不提供任何输出。

## 使用示例

### 基础预设标签

```hcl
module "preset_tag" {
  source = "./modules/preset-tag"

  preset_tags = [
    {
      key    = "Environment"
      values = ["production"]
    }
  ]
}
```

### 多个预设标签

```hcl
module "preset_tag" {
  source = "./modules/preset-tag"

  preset_tags = [
    {
      key    = "Environment"
      values = ["production", "staging", "development"]
    },
    {
      key    = "Project"
      values = ["landing-zone", "application"]
    },
    {
      key    = "Team"
      values = ["devops", "backend", "frontend"]
    }
  ]
}
```

## 注意事项

- 预设标签（元标签）是可重用的标签，可应用于资源
- 标签键不能以 "aliyun" 或 "acs:" 前缀开头
- 标签键和值不能包含 "http://" 或 "https://"
- 每个标签键可以有 1-10 个值
- 标签值限制为每个最多 128 个字符
- 预设标签有助于在资源间保持一致的标签

