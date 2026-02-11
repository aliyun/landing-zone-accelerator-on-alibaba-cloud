<div align="right">

**中文** | [English](README.md)

</div>

# Folders 组件

该组件用于创建和管理阿里云资源目录（Resource Manager Resource Directory）和分层文件夹结构。

## 功能特性

- 创建资源目录
- 创建分层文件夹结构（最多 5 层）
- 支持从文件（JSON/YAML）或内联变量配置文件夹
- 支持文件夹标签（tags）用于资源管理
- 验证文件夹结构和关系

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
| [alicloud_resource_manager_resource_directory.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/resource_manager_resource_directory) | resource | 资源目录 |
| [alicloud_resource_manager_resource_directories.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/resource_manager_resource_directories) | data source | 资源目录信息 |
| [alicloud_resource_manager_folder.level1-5](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/resource_manager_folder) | resource | 不同层级的文件夹 |

## 使用方法

```hcl
module "folders" {
  source = "./components/resource-structure/folders"
  
  folder_structure = [
    {
      folder_name        = "Core"
      parent_folder_name = null
      level              = 1
      tags               = {}
    },
    {
      folder_name        = "Production"
      parent_folder_name = null
      level              = 1
      tags               = {
        Environment = "Production"
        Team        = "Platform"
      }
    },
    {
      folder_name        = "Development"
      parent_folder_name = null
      level              = 1
      tags               = {}
    },
    {
      folder_name        = "Web-Services-Prod"
      parent_folder_name = "Production"
      level              = 2
      tags               = {
        Service     = "Web"
        Environment = "Production"
      }
    }
  ]
}
```

## 输入参数

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `folder_structure` | 要创建的文件夹配置列表 | `list(object)` | `[]` | No | 层级 1-5，有效的文件夹名称，正确的父子关系 |
| `folder_structure_file_path` | 定义文件夹结构的 JSON/YAML 文件路径 | `string` | `null` | No | 支持 .json, .yaml, .yml |
| `use_existing_resource_directory` | 是否使用已有的资源目录而不是创建新的。当设置为 true 时，如果管控策略未启用，需要手动启用。 | `bool` | `false` | No | - |

### folder_structure 对象

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `folder_name` | 文件夹名称 | `string` | Yes |
| `parent_folder_name` | 父文件夹名称（level 1 为 null） | `string` | No |
| `level` | 文件夹层级（1-5） | `number` | Yes |
| `tags` | 文件夹标签 | `map(string)` | No |

## 输出参数

| Name | Description |
|------|-------------|
| `resource_directory_id` | 资源目录 ID |
| `root_folder_id` | 根文件夹 ID |
| `folder_structure` | 包含 ID 的文件夹结构列表 |
| `folders_by_level` | 按层级分组的文件夹 |

## 使用示例

### 基础文件夹结构

```hcl
module "folders" {
  source = "./components/resource-structure/folders"
  
  folder_structure = [
    {
      folder_name        = "Core"
      parent_folder_name = null
      level              = 1
      tags               = {}
    },
    {
      folder_name        = "Production"
      parent_folder_name = null
      level              = 1
      tags               = {}
    },
    {
      folder_name        = "Development"
      parent_folder_name = null
      level              = 1
      tags               = {}
    }
  ]
}
```

### 使用文件配置

```hcl
module "folders" {
  source = "./components/resource-structure/folders"

  folder_structure_file_path = "./folders.yaml"
}
```

### 多层级结构

```hcl
module "folders" {
  source = "./components/resource-structure/folders"

  folder_structure = [
    {
      folder_name        = "Production"
      parent_folder_name = null
      level              = 1
      tags               = {}
    },
    {
      folder_name        = "Web-Services-Prod"
      parent_folder_name = "Production"
      level              = 2
      tags               = {
        Service     = "Web"
        Environment = "Production"
      }
    },
    {
      folder_name        = "Backend-Prod"
      parent_folder_name = "Web-Services-Prod"
      level              = 3
      tags               = {
        Component   = "Backend"
        Environment = "Production"
      }
    }
  ]
}
```

## 注意事项

- 资源目录默认会自动创建并启用（当 `use_existing_resource_directory` 为 `false` 时）
- 当 `use_existing_resource_directory` 设置为 `true` 时，组件将使用已有的资源目录，不会创建新的资源目录
- **重要**：创建新资源目录时，管控策略会自动启用。如果使用已有资源目录（`use_existing_resource_directory = true`），必须确保在阿里云控制台中已启用管控策略，如果未启用则需要手动启用
- 文件夹按层级顺序创建（从 level 1 到 5）
- 如果 folder_structure 中未包含核心文件夹，会自动创建
- 同一层级内的文件夹名称必须唯一
- Level 1 文件夹不能有 parent_folder_name
- Level 2-5 文件夹必须有 parent_folder_name
- 文件夹名称可以包含中文字符、英文字母、数字、下划线、点号和连字符
- 标签（tags）为可选，如果未指定则默认为空 map `{}`
- 当提供 folder_structure_file_path 时，会覆盖 folder_structure 变量
- 当同时提供目录配置和内联配置时，目录配置优先
