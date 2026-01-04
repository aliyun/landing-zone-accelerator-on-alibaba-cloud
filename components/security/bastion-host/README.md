<div align="right">

**English** | [中文](README-CN.md)

</div>

# Bastion Host Component

This component creates and manages Alibaba Cloud Bastion Host instances for secure server access.

## Features

- Creates Bastion Host instances
- Optionally creates VPC, VSwitch, and Security Group resources
- Configures SSH and HTTPS access rules
- Creates service-linked role for Bastion Host service
- Supports using existing VPC resources

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| alicloud | ~> 1.262.1 |

## Providers

| Name | Version |
|------|---------|
| alicloud | ~> 1.262.1 |

## Modules

| Name | Source | Description |
|------|--------|-------------|
| slr-with-service-name | terraform-alicloud-modules/service-linked-role/alicloud | Service-linked role for Bastion Host |

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_account.current](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | Current account information |
| [alicloud_vpc.bastion_vpc](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpc) | resource | VPC for Bastion Host (optional) |
| [alicloud_vswitch.bastion_vswitch](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource | VSwitch for Bastion Host (optional) |
| [alicloud_security_group.bastion_sg](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group) | resource | Security group for Bastion Host (optional) |
| [alicloud_security_group_rule.allow_ssh](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group_rule) | resource | SSH access rule (optional) |
| [alicloud_security_group_rule.allow_https](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group_rule) | resource | HTTPS access rule (optional) |
| [alicloud_bastionhost_instance.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/bastionhost_instance) | resource | Bastion Host instance |
| [null_resource.wait_for_service_init](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource | Wait for service initialization |

## Usage

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  create_bastion_host = true
  
  bastion_host_description = "Production Bastion Host"
  bastion_host_license_code = "bhah_ent_50_asset"
  bastion_host_plan_code = "cloudbastion"
  bastion_host_storage = "5"
  bastion_host_bandwidth = "5"
  bastion_host_period = 1
  
  create_vpc_resources = true
  vpc_cidr = "192.168.0.0/16"
  vswitch_cidr = "192.168.1.0/24"
  availability_zone = "cn-hangzhou-h"
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `create_bastion_host` | Controls if Bastion Host instance should be created | `bool` | `false` | No | - |
| `bastion_host_description` | Description of the Bastion Host instance | `string` | `""` | No | - |
| `bastion_host_license_code` | License code for the Bastion Host instance | `string` | `"bhah_ent_50_asset"` | No | - |
| `bastion_host_plan_code` | Plan code for the Bastion Host instance | `string` | `"cloudbastion"` | No | - |
| `bastion_host_storage` | Storage capacity for the Bastion Host instance | `string` | `"5"` | No | - |
| `bastion_host_bandwidth` | Bandwidth for the Bastion Host instance | `string` | `"5"` | No | - |
| `bastion_host_period` | Period of the Bastion Host instance | `number` | `1` | No | - |
| `create_vpc_resources` | Controls if VPC resources should be created | `bool` | `false` | No | - |
| `vpc_cidr` | CIDR block for the VPC | `string` | `"192.168.0.0/16"` | No | - |
| `vswitch_cidr` | CIDR block for the VSwitch | `string` | `"192.168.1.0/24"` | No | - |
| `availability_zone` | Availability zone for the VSwitch | `string` | `""` | No | Required when `create_vpc_resources = true` |
| `vpc_name` | Name of the VPC | `string` | `"bastion-host-vpc"` | No | - |
| `vswitch_name` | Name of the VSwitch | `string` | `"bastion-host-vswitch"` | No | - |
| `security_group_name` | Name of the security group | `string` | `"bastion-host-sg"` | No | - |
| `bastion_host_vswitch_id` | VSwitch ID for existing resources | `string` | `""` | No | Required when `create_vpc_resources = false` |
| `bastion_host_security_group_ids` | Security Group IDs for existing resources | `list(string)` | `[]` | No | Required when `create_vpc_resources = false` |
| `bastion_host_tags` | Tags for the Bastion Host instance | `map(string)` | `{Environment = "landingzone", Project = "terraform-alicloud-landing-zone-accelerator"}` | No | - |
| `ssh_rule_cidr_ip` | CIDR IP for SSH rule | `string` | `"0.0.0.0/0"` | No | - |
| `https_rule_cidr_ip` | CIDR IP for HTTPS rule | `string` | `"0.0.0.0/0"` | No | - |

## Outputs

| Name | Description |
|------|-------------|
| `bastion_host_instance_id` | The ID of the Bastion Host instance |
| `bastion_host_vpc_id` | The ID of the VPC for the Bastion Host |
| `bastion_host_vswitch_id` | The ID of the VSwitch for the Bastion Host |
| `bastion_host_security_group_id` | The ID of the security group for the Bastion Host |
| `service_linked_role_names` | The name of the service linked roles |

## Examples

### Create Bastion Host with VPC Resources

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  create_bastion_host = true
  create_vpc_resources = true
  
  vpc_cidr = "10.0.0.0/16"
  vswitch_cidr = "10.0.1.0/24"
  availability_zone = "cn-hangzhou-h"
  
  bastion_host_tags = {
    Environment = "production"
    Team        = "security"
  }
}
```

### Use Existing VPC Resources

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  create_bastion_host = true
  create_vpc_resources = false
  
  bastion_host_vswitch_id = "vsw-abc123"
  bastion_host_security_group_ids = ["sg-xyz789"]
}
```

## Notes

- Bastion Host service requires a service-linked role which is automatically created
- When creating VPC resources, the component waits 60 seconds for service initialization
- SSH and HTTPS rules are configured to allow access from specified CIDR blocks
- Storage and bandwidth values determine the instance specifications
- Period is in months (minimum 1)

