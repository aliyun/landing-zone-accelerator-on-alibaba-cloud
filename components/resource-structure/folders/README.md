<div align="right">

**English** | [中文](README-CN.md)

</div>

# Folders Component

This component creates and manages Alibaba Cloud Resource Manager Resource Directory and hierarchical folder structure.

## Features

- Creates Resource Directory
- Creates hierarchical folder structure (up to 5 levels)
- Supports folder configuration from file (JSON/YAML) or inline variables
- Supports folder tags for resource management
- Validates folder structure and relationships

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |

## Modules

No modules.

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_resource_manager_resource_directory.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/resource_manager_resource_directory) | resource | Resource Directory |
| [alicloud_resource_manager_resource_directories.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/resource_manager_resource_directories) | data source | Resource Directory information |
| [alicloud_resource_manager_folder.level1-5](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/resource_manager_folder) | resource | Folders at different levels |

## Usage

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

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `folder_structure` | List of folder configurations to create | `list(object)` | `[]` | No | Level 1-5, valid folder names, proper parent relationships |
| `folder_structure_file_path` | Path to JSON/YAML file defining folder structure | `string` | `null` | No | Supports .json, .yaml, .yml |
| `use_existing_resource_directory` | Whether to use an existing resource directory instead of creating a new one. When true, control policy must be manually enabled if not already enabled. | `bool` | `false` | No | - |

### folder_structure Object

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `folder_name` | Name of the folder | `string` | Yes |
| `parent_folder_name` | Name of parent folder (null for level 1) | `string` | No |
| `level` | Folder level (1-5) | `number` | Yes |
| `tags` | Tags for the folder | `map(string)` | No |

## Outputs

| Name | Description |
|------|-------------|
| `resource_directory_id` | The ID of the resource directory |
| `root_folder_id` | The ID of the root folder |
| `folder_structure` | The folder structure as a list with IDs |
| `folders_by_level` | Folders grouped by level |

## Examples

### Basic Folder Structure

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

### Using File Configuration

```hcl
module "folders" {
  source = "./components/resource-structure/folders"

  folder_structure_file_path = "./folders.yaml"
}
```

### Multi-Level Hierarchy

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

## Notes

- Resource Directory is automatically created and enabled by default (when `use_existing_resource_directory` is `false`)
- When `use_existing_resource_directory` is `true`, the component will use an existing resource directory and will not create a new one
- **Important**: When creating a new resource directory, control policy is automatically enabled. If you use an existing resource directory (`use_existing_resource_directory = true`), you must manually ensure that control policy is enabled in the Alibaba Cloud console if it's not already enabled
- Folders are created in hierarchical order (level 1 to 5)
- Core folder is automatically created if not present in folder_structure
- Folder names must be unique within the same level
- Level 1 folders must not have parent_folder_name
- Level 2-5 folders must have parent_folder_name
- Folder names can contain Chinese characters, English letters, numbers, underscores, periods, and hyphens
- Tags are optional and default to empty map `{}` if not specified
- When folder_structure_file_path is provided, it overrides folder_structure variable
- Directory configuration takes precedence over inline configuration when both are provided
