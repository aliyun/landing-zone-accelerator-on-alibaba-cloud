<div align="right">

**English** | [中文](README-CN.md)

</div>

# Bastion Host Component

This component creates and manages Alibaba Cloud Bastion Host instances for secure server access.

## Features

- Automatically creates Service Linked Role (SLR) for Bastion Host service (`AliyunServiceRoleForBastionhost`)
- Creates Bastion Host instances
- Imports ECS instances to Bastion Host
- Creates Bastion Host asset groups
- Creates and manages host accounts
- Configures host-to-asset-group associations (supports one host belonging to multiple asset groups)
- Supports configuring multiple AD authentication servers
- Supports configuring multiple LDAP authentication servers
- Supports using existing Bastion Host instances (via `existing_bastion_instance_id`)
- Supports using existing hosts (via `existing_host_id`)
- Supports using existing asset groups (via `host_group_name`)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | ~> 1.267.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | ~> 1.267.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| bastion-host-slr | terraform-alicloud-modules/service-linked-role/alicloud | 1.2.0 |

## Resources

| Name | Type | Description |
|------|------|-------------|
| [module.bastion-host-slr](https://registry.terraform.io/modules/terraform-alicloud-modules/service-linked-role/alicloud/latest) | module | Service Linked Role for Bastion Host service |
| [alicloud_bastionhost_instance.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/bastionhost_instance) | resource | Bastion Host instance |
| [alicloud_bastionhost_host.hosts](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/bastionhost_host) | resource | Bastion Host hosts |
| [alicloud_bastionhost_host_group.groups](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/bastionhost_host_group) | resource | Bastion Host asset groups |
| [alicloud_bastionhost_host_account.accounts](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/bastionhost_host_account) | resource | Bastion Host host accounts |
| [alicloud_bastionhost_host_attachment.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/bastionhost_host_attachment) | resource | Bastion Host host-to-asset-group associations |

## Usage

### Basic Configuration

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  # Service Linked Role configuration (optional, defaults to true)
  create_bastion_host_slr = true  # Creates AliyunServiceRoleForBastionhost
  
  create_bastion_host = true
  
  bastionhost_description = "Production Bastion Host"
  bastionhost_license_code = "bhah_ent_50_asset"
  bastionhost_plan_code = "cloudbastion"
  bastionhost_storage = 5
  bastionhost_bandwidth = 5
  bastionhost_period = 1
  bastionhost_vswitch_id = "vsw-xxxxxxxxxxxx"
  bastionhost_security_group_ids = ["sg-xxxxxxxxxxxx"]
  bastionhost_slave_vswitch_id = "vsw-xxxxxxxxxxxx"

  bastionhost_host_groups = [{
    host_group_name = "group_test"
    comment         = "Test Bastion Host Group"
  }]

  # Host configuration methods see below
}
```

### Host Configuration Methods

#### Method 1: Direct Configuration

Configure hosts directly using the `bastionhost_hosts` parameter in Terraform code:

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  # ... other configurations ...

  bastionhost_hosts = [
    {
      host_config = {
        active_address_type  = "Private"
        comment              = "Test Bastion Host"
        host_name            = "web-server-1"
        host_private_address = "192.168.0.27"
        os_type              = "Linux"
        source               = "Ecs"
        source_instance_id   = "i-xxxxxxxxxxxx"
      }
      host_group_names = ["group_test"]
      host_accounts = [
        {
          protocol_name     = "SSH"
          host_account_name = "account1"
          password          = "your-password"
        }
      ]
    },
    {
      existing_host_id  = "xx"
      host_group_names  = ["group_test"]
      host_accounts = [
        {
          protocol_name     = "SSH"
          host_account_name = "account1"
          password          = "your-password"
        }
      ]
    }
  ]
}
```

#### Method 2: Load from Files

Load host configurations from YAML/JSON files using `host_file_paths` or `host_dir_paths` parameters:

**Method 2.1: Load from Single or Multiple Files**

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  # ... other configurations ...

  host_file_paths = [
    "./configs/hosts_production.json",
    "./configs/hosts_staging.yaml"
  ]
}
```

**Method 2.2: Load from Directory**

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  # ... other configurations ...

  host_dir_paths = [
    "./configs/hosts/"
  ]
}
```

**Method 2.3: Mixed Usage**

You can use both direct configuration and file loading together, configurations will be merged:

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  # ... other configurations ...

  # Directly configured hosts
  bastionhost_hosts = [
    {
      host_config = {
        active_address_type  = "Private"
        host_private_address = "192.168.1.10"
        os_type              = "Linux"
        source               = "Ecs"
        source_instance_id   = "i-abc123"
      }
      host_group_names = ["direct-config"]
    }
  ]

  # Hosts loaded from files
  host_file_paths = ["./configs/hosts.json"]
  host_dir_paths  = ["./configs/hosts/"]
}
```

**File Format Description:**

Files must be in YAML or JSON format containing an array of host objects.

**JSON Format Example (hosts.json):**

```json
[
  {
    "existing_host_id": null,
    "host_config": {
      "active_address_type": "Private",
      "comment": "Test Bastion Host",
      "host_name": "web-server-1",
      "host_private_address": "192.168.0.27",
      "host_public_address": null,
      "instance_region_id": "cn-shanghai",
      "os_type": "Linux",
      "source": "Ecs",
      "source_instance_id": "i-xxxxxxxxxxxx"
    },
    "host_group_names": ["group_test"],
    "host_accounts": [
      {
        "protocol_name": "SSH",
        "host_account_name": "account1",
        "password": "your-password"
      }
    ]
  }
]
```

**YAML Format Example (hosts.yaml):**

```yaml
- existing_host_id: null
  host_config:
    active_address_type: "Private"
    comment: "Test Bastion Host"
    host_name: "web-server-1"
    host_private_address: "192.168.0.27"
    host_public_address: null
    instance_region_id: "cn-shanghai"
    os_type: "Linux"
    source: "Ecs"
    source_instance_id: "i-xxxxxxxxxxxx"
  host_group_names:
    - "group_test"
  host_accounts:
    - protocol_name: "SSH"
      host_account_name: "account1"
      password: "your-password"
```

## Inputs

### Basic Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `create_bastion_host_slr` | Controls if Bastion Host Service Linked Role should be created. When enabled, creates `AliyunServiceRoleForBastionhost` role automatically | `bool` | `true` | No |
| `create_bastion_host` | Controls if Bastion Host instance should be created | `bool` | `true` | No |
| `existing_bastion_instance_id` | ID of the existing Bastion Host instance | `string` | `null` | No |

### Bastion Host Instance Configuration

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `bastionhost_description` | Description of the Bastion Host instance | `string` | `null` | Yes* | 1-63 characters, required when `create_bastion_host=true` |
| `bastionhost_license_code` | License code for the Bastion Host instance | `string` | `null` | Yes* | Must match pattern `bhah_ent_xxx_asset` (xxx can be any value), required when `create_bastion_host=true` |
| `bastionhost_plan_code` | Plan code for the Bastion Host instance | `string` | `null` | Yes* | `cloudbastion` or `cloudbastion_ha`, required when `create_bastion_host=true` |
| `bastionhost_storage` | Storage capacity (GB) | `number` | `null` | Yes* | 0-500, required when `create_bastion_host=true` |
| `bastionhost_bandwidth` | Bandwidth (Mbps) | `number` | `null` | Yes* | 0-150, must be a multiple of 5, required when `create_bastion_host=true` |
| `bastionhost_period` | Subscription period (months) | `number` | `null` | No | 1-9, 12, 24, 36 |
| `bastionhost_vswitch_id` | Primary VSwitch ID | `string` | `null` | Yes* | Required when `create_bastion_host=true` |
| `bastionhost_slave_vswitch_id` | Slave VSwitch ID (HA mode) | `string` | `null` | No | Can only be set when `bastionhost_plan_code="cloudbastion_ha"` |
| `bastionhost_security_group_ids` | Security group ID list | `set(string)` | `[]` | Yes* | Required when `create_bastion_host=true`, must contain at least one security group ID |
| `bastionhost_tags` | Tags | `map(string)` | `null` | No | - |
| `bastionhost_resource_group_id` | Resource group ID | `string` | `null` | No | - |
| `bastionhost_enable_public_access` | Enable public access | `bool` | `null` | No | - |
| `bastionhost_ad_auth_server` | AD authentication server configuration list | `list(object)` | `null` | No | See detailed description below |
| `bastionhost_ldap_auth_server` | LDAP authentication server configuration list | `list(object)` | `null` | No | See detailed description below |
| `bastionhost_renew_period` | Renewal period | `number` | `null` | No | 1-9, 12, 24, 36, required when `renewal_status="AutoRenewal"` |
| `bastionhost_renewal_status` | Renewal status | `string` | `null` | No | `AutoRenewal`, `ManualRenewal`, `NotRenewal` |
| `bastionhost_renewal_period_unit` | Renewal period unit | `string` | `null` | No | `M` or `Y` |
| `bastionhost_public_white_list` | Public whitelist IP list | `list(string)` | `[]` | No | - |

**bastionhost_ad_auth_server Object Structure:**

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `account` | Account | `string` | Yes |
| `base_dn` | Base DN | `string` | Yes |
| `domain` | Domain | `string` | Yes |
| `email_mapping` | Email mapping | `string` | No |
| `filter` | Filter | `string` | No |
| `is_ssl` | Use SSL | `bool` | Yes |
| `mobile_mapping` | Mobile mapping | `string` | No |
| `name_mapping` | Name mapping | `string` | No |
| `password` | Password | `string` | No |
| `port` | Port | `number` | Yes |
| `server` | Server address | `string` | Yes |
| `standby_server` | Standby server address | `string` | No |

**bastionhost_ldap_auth_server Object Structure:**

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `account` | Account | `string` | Yes |
| `base_dn` | Base DN | `string` | Yes |
| `email_mapping` | Email mapping | `string` | No |
| `filter` | Filter | `string` | No |
| `is_ssl` | Use SSL | `bool` | No |
| `login_name_mapping` | Login name mapping | `string` | No |
| `mobile_mapping` | Mobile mapping | `string` | No |
| `name_mapping` | Name mapping | `string` | No |
| `password` | Password | `string` | No |
| `port` | Port | `number` | Yes |
| `server` | Server address | `string` | Yes |
| `standby_server` | Standby server address | `string` | No |

### Asset Group Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `bastionhost_host_groups` | Asset group configuration list | `list(object)` | `[]` | No |

**bastionhost_host_groups Object Structure:**

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `host_group_name` | Asset group name | `string` | Yes |
| `comment` | Comment | `string` | No |

### Host Configuration

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `bastionhost_hosts` | Host configuration list | `list(object)` | `[]` | No | See detailed description below |
| `host_file_paths` | Host configuration file path list (YAML/JSON) | `list(string)` | `[]` | No | Files must contain an array of host objects |
| `host_dir_paths` | Host configuration directory path list (YAML/JSON) | `list(string)` | `[]` | No | Files in directories will be loaded, files must contain an array of host objects |

**bastionhost_hosts Object Structure:**

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `existing_host_id` | Existing host ID | `string` | `null` | No | Either this or `host_config` must be provided |
| `host_config` | Host configuration object | `object` | `null` | No | See detailed description below (either this or `existing_host_id` must be provided) |
| `host_group_names` | Asset group name list | `list(string)` | `[]` | No | One host can belong to multiple asset groups |
| `host_accounts` | Host account list | `list(object)` | `[]` | No | See detailed description below |

**host_config Object Structure:**

| Name | Description | Type | Required | Constraints |
|------|-------------|------|----------|-------------|
| `active_address_type` | Active address type | `string` | Yes | `Public` or `Private` |
| `comment` | Comment | `string` | No | 1-500 characters |
| `host_name` | Host name | `string` | No | 1-128 characters |
| `host_private_address` | Host private address | `string` | Yes* | Required when `active_address_type="Private"` |
| `host_public_address` | Host public address | `string` | No | - |
| `instance_region_id` | Instance region ID | `string` | No | - |
| `os_type` | Operating system type | `string` | Yes | `Linux` or `Windows` |
| `source` | Source | `string` | Yes | `Local`, `Ecs`, `Rds` |
| `source_instance_id` | Source instance ID (ECS ID) | `string` | Yes* | Required when `source="Ecs"` or `source="Rds"` |

**host_accounts Object Structure:**

| Name | Description | Type | Required | Constraints |
|------|-------------|------|----------|-------------|
| `host_account_name` | Account name | `string` | Yes | 1-128 characters |
| `pass_phrase` | Passphrase (SSH protocol) | `string` | No | - |
| `password` | Password | `string` | No | - |
| `private_key` | Private key (SSH protocol) | `string` | No | - |
| `protocol_name` | Protocol name | `string` | Yes | `SSH` or `RDP` |

## Outputs

| Name | Description |
|------|-------------|
| `bastionhost_instance_id` | Bastion Host instance ID |
| `bastionhost_instance_info` | Bastion Host instance information |
| `bastionhost_host_group_maps` | Bastion Host asset groups (map format, keyed by host_group_name) |
| `bastionhost_hosts_list` | Bastion Host host list |
| `bastionhost_host_accounts_list` | Bastion Host asset account list (includes password information) |

## Examples

### Create and Enable Bastion Host

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  create_bastion_host = true
  
  bastionhost_description = "Production Bastion Host"
  bastionhost_license_code = "bhah_ent_50_asset"
  bastionhost_plan_code = "cloudbastion_ha"
  bastionhost_storage = 5
  bastionhost_bandwidth = 5
  bastionhost_period = 1

  bastionhost_vswitch_id = "vsw-xxxxxxxxxxxx"
  bastionhost_security_group_ids = ["sg-xxxxxxxxxxxx"]
  bastionhost_slave_vswitch_id = "vsw-xxxxxxxxxxxx"
}
```

### Import Hosts and Create Host Accounts

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  create_bastion_host = true
  # ... other configurations ...
  
  bastionhost_host_groups = [
    {
      host_group_name = "web-servers"
      comment         = "Web Server Group"
    }
  ]

  bastionhost_hosts = [
    {
      host_config = {
        active_address_type  = "Private"
        host_private_address = "192.168.1.10"
        os_type             = "Linux"
        source              = "Ecs"
        source_instance_id  = "i-xxxxxxxxxxxx"
        host_name           = "web-server-1"
      }
      host_accounts = [
        {
          host_account_name = "root"
          protocol_name     = "SSH"
          password          = "your-password"
        }
      ]
      host_group_names = ["web-servers"]
    }
  ]
}
```

### Use Existing Bastion Host Instance

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  create_bastion_host = false
  existing_bastion_instance_id = "bastionhost-cn-hangzhou-abc123"
  
  bastionhost_hosts = [
    {
      existing_host_id    = "host-xyz789"
      host_group_names    = ["existing-group"]
    }
  ]
}
```

### Configure AD/LDAP Authentication Servers

```hcl
module "bastion_host" {
  source = "./components/security/bastion-host"

  create_bastion_host = true
  # ... other configurations ...
  
  bastionhost_ad_auth_server = [
    {
      server         = "192.168.1.1"
      standby_server = "192.168.1.3"
      port           = 389
      domain         = "example.com"
      account        = "cn=Manager,dc=example,dc=com"
      password       = "your-password"
      filter         = "objectClass=person"
      name_mapping   = "nameAttr"
      email_mapping  = "emailAttr"
      mobile_mapping = "mobileAttr"
      is_ssl         = false
      base_dn        = "dc=example,dc=com"
    }
  ]
  
  bastionhost_ldap_auth_server = [
    {
      server             = "192.168.1.1"
      standby_server     = "192.168.1.3"
      port               = 389
      login_name_mapping = "uid"
      account            = "cn=Manager,dc=example,dc=com"
      password           = "your-password"
      filter             = "objectClass=person"
      name_mapping       = "nameAttr"
      email_mapping      = "emailAttr"
      mobile_mapping      = "mobileAttr"
      is_ssl             = false
      base_dn            = "dc=example,dc=com"
    }
  ]
}
```

## Notes

- **Service Linked Role (SLR)**: By default, this component automatically creates the Service Linked Role `AliyunServiceRoleForBastionhost` required by the Bastion Host service. You can control this behavior using the `create_bastion_host_slr` variable (defaults to `true`). The SLR is created before the Bastion Host instance to ensure proper service initialization.
- In host configuration, if `existing_host_id` is not empty, the existing host will be used; otherwise, host configuration information must be provided in `host_config`
- `host_group_names` is a list type, one host can belong to multiple asset groups
- Supports loading host configurations from files or directories via `host_file_paths` and `host_dir_paths` (YAML/JSON format), file content must be an array of host objects
- When `protocol_name` is `SSH`, you can use `private_key` or `pass_phrase`; when it's `RDP`, use `password`
- AD and LDAP authentication servers support configuring multiple instances, use list format
- License code supports `bhah_ent_xxx_asset` format, where `xxx` supports 50\100\200\500\1000\2000\5000\10000
- Storage and bandwidth values determine instance specifications
- Subscription period unit is months (1-9, 12, 24, 36)
- When `create_bastion_host=true`, the following parameters are required: `bastionhost_description`, `bastionhost_license_code`, `bastionhost_plan_code`, `bastionhost_storage`, `bastionhost_bandwidth`, `bastionhost_vswitch_id`, `bastionhost_security_group_ids` (must contain at least one security group ID)
- When `bastionhost_plan_code="cloudbastion_ha"`, you can set `bastionhost_slave_vswitch_id`; in other cases, `bastionhost_slave_vswitch_id` must be `null`
- Bastion Host requires `bastionhost_vswitch_id` and `bastionhost_security_group_ids` to be specified before it can be enabled
