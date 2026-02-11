<div align="right">

**English** | [中文](README-CN.md)

</div>

# Config Configuration Recorder Module

This module enables Alibaba Cloud Config service.

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
| [alicloud_config_configuration_recorder.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/config_configuration_recorder) | resource | Config Configuration Recorder |

## Usage

```hcl
module "config_recorder" {
  source = "./modules/config-configuration-recorder"
}
```

## Inputs

This module does not require any input variables. It creates a configuration recorder with default settings.

## Outputs

| Name | Description |
|------|-------------|
| `recorder_id` | The ID of the configuration recorder |
| `status` | The status of the configuration recorder |

## Examples

### Basic Usage

```hcl
module "config_recorder" {
  source = "./modules/config-configuration-recorder"
}
```


