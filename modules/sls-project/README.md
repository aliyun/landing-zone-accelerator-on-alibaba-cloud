<div align="right">

**English** | [中文](README-CN.md)

</div>

# SLS Project Module

This module creates and manages Alibaba Cloud Simple Log Service (SLS) projects.

## Features

- Creates new SLS project or references existing project
- Supports random suffix for project name uniqueness
- Configures project description and tags

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| alicloud | >= 1.262.1 |
| random | >= 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.262.1 |
| random | >= 3.6.0 |

## Modules

No modules.

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_account.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | Current account information |
| [alicloud_regions.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/regions) | data source | Current region information |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource | Random suffix for project name (optional) |
| [alicloud_log_project.project](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/log_project) | resource | SLS project (when create_project = true) |

## Usage

```hcl
module "sls_project" {
  source = "./modules/sls-project"

  project_name = "my-log-project"
  description  = "My log project"
  
  tags = {
    Environment = "production"
    Project     = "logging"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `project_name` | The name of the SLS project | `string` | - | Yes | 3-63 characters, start/end with lowercase letter or digit, only lowercase letters, digits and hyphens |
| `create_project` | Whether to create a new SLS project | `bool` | `true` | No | - |
| `append_random_suffix` | Whether to append a random suffix to project_name for uniqueness | `bool` | `false` | No | Only when `create_project = true` |
| `random_suffix_length` | Length of the random suffix | `number` | `6` | No | Must be between 3 and 16 |
| `random_suffix_separator` | Separator between project_name and random suffix | `string` | `"-"` | No | Must be: `"-"`, `"_"`, or `""` |
| `description` | The description of the SLS project | `string` | `""` | No | - |
| `tags` | A mapping of tags to assign to the project | `map(string)` | `null` | No | - |

## Outputs

| Name | Description |
|------|-------------|
| `project_name` | The name of the SLS project (with random suffix if enabled) |
| `project_description` | The description of the SLS project |
| `project_arn` | The ARN of the SLS project in format: `acs:log:{region}:{account_id}:project/{project_name}` |

## Examples

### Basic SLS Project

```hcl
module "sls_project" {
  source = "./modules/sls-project"

  project_name = "my-log-project"
  description  = "Application logs"
}
```

### SLS Project with Random Suffix

```hcl
module "sls_project" {
  source = "./modules/sls-project"

  project_name         = "my-log-project"
  append_random_suffix = true
  random_suffix_length = 8
  description          = "Application logs"
}
```

### Reference Existing Project

```hcl
module "sls_project" {
  source = "./modules/sls-project"

  project_name  = "existing-project"
  create_project = false
}
```

### SLS Project with Tags

```hcl
module "sls_project" {
  source = "./modules/sls-project"

  project_name = "production-logs"
  description  = "Production environment logs"
  
  tags = {
    Environment = "production"
    Team        = "devops"
    Project     = "landing-zone"
  }
}
```

## Notes

- Project names must be globally unique across all Alibaba Cloud accounts
- Use `append_random_suffix` to ensure uniqueness when project name conflicts are possible
- When `create_project = false`, the module references an existing project (project must exist)
- Random suffix is only appended when both `create_project = true` and `append_random_suffix = true`
- Project names must start and end with lowercase letters or digits
- Project names can only contain lowercase letters, digits, and hyphens

