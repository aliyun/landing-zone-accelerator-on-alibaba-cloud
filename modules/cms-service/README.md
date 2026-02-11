<div align="right">

**English** | [中文](README-CN.md)

</div>

# CMS Service Module

This module enables Alibaba Cloud CloudMonitor (CMS) Basic and optionally Enterprise editions.

## Features

- Enable CloudMonitor Basic edition (always enabled)
- Optionally enable CloudMonitor Enterprise edition
- Create the required service-linked role for CloudMonitor

## Inputs

| Name              | Description                                                    | Type  | Default | Required |
|-------------------|----------------------------------------------------------------|-------|---------|----------|
| `enable_enterprise` | Whether to enable CloudMonitor Enterprise edition. If `false`, only Basic edition is enabled. | `bool` | `false` | No       |

## Outputs

| Name                             | Description                                                |
|----------------------------------|------------------------------------------------------------|
| `basic_cloud_monitor_service_id` | The ID of the Basic CloudMonitor service.                 |
| `enterprise_cloud_monitor_service_id` | The ID of the Enterprise CloudMonitor service (null if not enabled). |

## Usage

```hcl
module "cms_service" {
  source = "./modules/cms-service"

  enable_enterprise = true
}
```


