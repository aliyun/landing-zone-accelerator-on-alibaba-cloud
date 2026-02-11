<div align="right">

**English** | [中文](README-CN.md)

</div>

## Baseline VPC Component

This component creates multiple baseline VPCs (via `modules/vpc`), and optionally:

- Attaches the VPCs to a CEN transit router (via `modules/cen-vpc-attach`)

## Features

- Create multiple VPCs, VSwitches and optional Network ACLs for an account baseline
- Optionally attach all VPCs to a CEN Transit Router with shared configuration
- Each VPC can have its own CEN attachment settings while sharing common CEN configuration

## Requirements

| Name      | Version   |
|----------|-----------|
| terraform | >= 1.2  |
| alicloud  | >= 1.267.0 |

## Providers

| Name          | Version   |
|---------------|-----------|
| alicloud       | >= 1.267.0 |
| alicloud.vpc   | >= 1.267.0 |
| alicloud.cen_tr | >= 1.267.0 |

This component expects the `alicloud` provider to expose the following **configuration aliases** (see `versions.tf` and stack-level provider config):

- `alicloud.vpc` – used for VPC resources
- `alicloud.cen_tr` – used for CEN / Transit Router attachment

When using this component directly in Terraform (instead of via `tfcomponent.yaml`), you must define these aliases and wire them into the module, for example:

```hcl
provider "alicloud" {
  alias  = "vpc"
  region = "cn-hangzhou"
}

module "baseline_vpc_networkings" {
  source = "./components/account-factory/baseline/vpc-baseline"

  providers = {
    alicloud.vpc    = alicloud.vpc
    alicloud.cen_tr = alicloud.cen_tr
  }

  # Common CEN configuration (shared across all VPCs)
  cen_attachment_enabled = true
  cen_instance_id       = "cen-xxxxx"
  cen_tr_id             = "tr-xxxxx"
  cen_tr_route_table_id = "vtb-xxxxx"

  # VPC networks configuration
  vpcs = [
    {
      vpc_name = "VPC-Prod-1"
      vpc_cidr = "10.0.0.0/16"
      vswitches = [
        {
          cidr_block = "10.0.1.0/24"
          zone_id    = "cn-hangzhou-h"
          purpose    = "TR"
        },
        {
          cidr_block = "10.0.2.0/24"
          zone_id    = "cn-hangzhou-i"
          purpose    = "TR"
        },
        {
          cidr_block = "10.0.3.0/24"
          zone_id    = "cn-hangzhou-j"
        }
      ]
      cen_attachment = {
        cen_tr_attachment_name = "To_VPC-Prod-1"
        vpc_route_entries = [
          {
            destination_cidrblock = "0.0.0.0/0"
          }
        ]
      }
    }
  ]
}
```

## Usage Examples

### Method 1: Direct Configuration

```hcl
module "baseline_vpc_networkings" {
  source = "./components/account-factory/baseline/vpc-baseline"

  providers = {
    alicloud.vpc    = alicloud.vpc
    alicloud.cen_tr = alicloud.cen_tr
  }

  # Common CEN configuration
  cen_attachment_enabled = true
  cen_instance_id       = "cen-xxxxxxxxxxxxx"
  cen_tr_id             = "tr-xxxxxxxxxxxxx"
  cen_tr_route_table_id = "vtb-xxxxxxxxxxxxx"

  vpcs = [
    {
      vpc_name = "VPC-SH-Prod-App"
      vpc_cidr = "10.220.0.0/16"
      vswitches = [
        {
          vswitch_name = "vsw-sh-prod-app-01"
          vswitch_cidr = "10.220.1.0/24"
          zone_id      = "cn-shanghai-e"
          purpose      = "TR"
        }
      ]
      cen_attachment = {
        cen_tr_attachment_name = "tr-attach-sh-prod-app"
      }
    }
  ]
}
```

### Method 2: Load from Directory

```hcl
module "baseline_vpc_networkings" {
  source = "./components/account-factory/baseline/vpc-baseline"

  providers = {
    alicloud.vpc    = alicloud.vpc
    alicloud.cen_tr = alicloud.cen_tr
  }

  # Common CEN configuration
  cen_attachment_enabled = true
  cen_instance_id       = "cen-xxxxxxxxxxxxx"
  cen_tr_id             = "tr-xxxxxxxxxxxxx"
  cen_tr_route_table_id = "vtb-xxxxxxxxxxxxx"

  vpc_dir_path = "./vpcs"
}
```

All `.json`, `.yaml`, and `.yml` files in the directory and subdirectories will be processed. Each file must contain a single VPC object.

**Example VPC file (YAML) - Single VPC Object:**

```yaml
# vpc-sh-prod-app.yaml
vpc_name: VPC-SH-Prod-App
vpc_cidr: 10.220.0.0/16
vswitches:
  - vswitch_name: vsw-sh-prod-app-01
    vswitch_cidr: 10.220.1.0/24
    zone_id: cn-shanghai-e
    purpose: TR
  - vswitch_name: vsw-sh-prod-app-02
    vswitch_cidr: 10.220.2.0/24
    zone_id: cn-shanghai-f
    purpose: TR
cen_attachment:
  cen_tr_attachment_name: tr-attach-sh-prod-app
```

### Method 3: Combined Configuration

```hcl
module "baseline_vpc_networkings" {
  source = "./components/account-factory/baseline/vpc-baseline"

  providers = {
    alicloud.vpc    = alicloud.vpc
    alicloud.cen_tr = alicloud.cen_tr
  }

  # Common CEN configuration
  cen_attachment_enabled = true
  cen_instance_id       = "cen-xxxxxxxxxxxxx"
  cen_tr_id             = "tr-xxxxxxxxxxxxx"
  cen_tr_route_table_id = "vtb-xxxxxxxxxxxxx"

  # Direct VPCs
  vpcs = [
    {
      vpc_name = "VPC-SH-Prod-App"
      vpc_cidr = "10.220.0.0/16"
      vswitches = [
        {
          vswitch_name = "vsw-sh-prod-app-01"
          vswitch_cidr = "10.220.1.0/24"
          zone_id      = "cn-shanghai-e"
          purpose      = "TR"
        }
      ]
      cen_attachment = {
        cen_tr_attachment_name = "tr-attach-sh-prod-app"
      }
    }
  ]

  # Load additional VPCs from directory
  vpc_dir_path = "./vpcs"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `cen_attachment_enabled` | Whether to enable CEN transit router attachment for all VPCs | `bool` | `false` | No |
| `cen_instance_id` | The ID of the CEN instance (shared for all VPCs) | `string` | `null` | No |
| `cen_tr_id` | The ID of the CEN Transit Router (shared for all VPCs) | `string` | `null` | No |
| `cen_tr_route_table_id` | The ID of the CEN Transit Router route table (shared for all VPCs) | `string` | `""` | No |
| `cen_service_linked_role_exists` | Whether the CEN service-linked role already exists. If true, the module will not create the service-linked role. If false, the module will create it | `bool` | `true` | No |
| `create_cen_instance_grant` | Whether to create CEN instance grant for cross-account attachment. **Must be set to `true` when CEN and VPC are in different accounts, and `false` when they are in the same account.** The module will validate this configuration against actual account IDs | `bool` | `true` | No |
| `vpcs` | List of VPC networking configurations | `list(object)` | `[]` | No |
| `vpc_dir_path` | Directory path containing VPC configuration files (YAML/JSON). Each file in this directory must contain a single VPC object. Files will be loaded and combined with vpcs | `string` | `null` | No |

### vpcs Object

Each VPC in `vpcs` can have the following structure:

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `vpc_name` | The name of the VPC | `string` | Yes |
| `vpc_cidr` | The CIDR block of the VPC | `string` | Yes |
| `vpc_description` | The description of the VPC | `string` | No |
| `enable_ipv6` | Whether to enable IPv6 for the VPC | `bool` | No |
| `ipv6_isp` | The type of IPv6 CIDR block | `string` | No |
| `resource_group_id` | The ID of the resource group | `string` | No |
| `user_cidrs` | List of user CIDR blocks | `list(string)` | No |
| `ipv4_cidr_mask` | Allocate VPC from the IPAM address pool by entering a mask | `number` | No |
| `ipv4_ipam_pool_id` | The ID of the IPAM pool | `string` | No |
| `ipv6_cidr_block` | The IPv6 CIDR block of the VPC | `string` | No |
| `vpc_tags` | Tags of the VPC | `map(string)` | No |
| `vswitches` | List of VSwitches | `list(object)` | Yes |

### vswitches Object

Each vswitch in `vswitches` can have the following structure:

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `cidr_block` | The CIDR block of the vswitch | `string` | Yes |
| `zone_id` | The zone ID where the vswitch is located | `string` | Yes |
| `vswitch_name` | The name of the vswitch | `string` | No |
| `description` | The description of the vswitch | `string` | No |
| `enable_ipv6` | Whether to enable IPv6 for the vswitch | `bool` | No |
| `ipv6_cidr_block_mask` | The mask for IPv6 CIDR block | `number` | No |
| `tags` | Tags for the vswitch | `map(string)` | No |
| `purpose` | Purpose of the vswitch: `null` or `"TR"`. Vswitches with `purpose="TR"` are used for Transit Router attachment | `string` | No |
| `enable_acl` | Whether to enable VPC Network ACL | `bool` | No |
| `acl_name` | The name of the network ACL | `string` | No |
| `acl_description` | The description of the network ACL | `string` | No |
| `acl_tags` | The tags of the network ACL | `map(string)` | No |
| `ingress_acl_entries` | List of ingress ACL entries | `list(object)` | No |
| `egress_acl_entries` | List of egress ACL entries | `list(object)` | No |
| `cen_attachment` | VPC-specific CEN attachment configuration | `object` | No |

### cen_attachment Object (VPC-specific)

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `cen_tr_attachment_name` | The name of the Transit Router VPC attachment | `string` | `""` |
| `cen_tr_attachment_description` | The description of the Transit Router VPC attachment | `string` | `""` |
| `cen_tr_route_table_association_enabled` | Whether to enable route table association | `bool` | `true` |
| `cen_tr_route_table_propagation_enabled` | Whether to enable route table propagation | `bool` | `true` |
| `cen_tr_attachment_auto_publish_route_enabled` | Whether to automatically publish routes | `bool` | `false` |
| `cen_tr_attachment_force_delete` | Whether to forcibly delete the attachment | `bool` | `false` |
| `cen_tr_attachment_payment_type` | The payment type of the attachment | `string` | `"PayAsYouGo"` |
| `cen_tr_attachment_tags` | Tags for the Transit Router VPC attachment | `map(string)` | `{}` |
| `cen_tr_attachment_options` | Options for the Transit Router VPC attachment | `map(string)` | `{"ipv6Support" = "disable"}` |
| `cen_tr_attachment_resource_type` | The resource type of the attachment | `string` | `"VPC"` |
| `vpc_route_entries` | List of route entries to add to the VPC route table | `list(object)` | `[]` |

## Outputs

| Name | Description |
|------|-------------|
| `vpcs` | Map of all created VPCs, keyed by vpc_name, including VPC details and CEN attachment IDs |
| `vpc_ids` | Map of VPC IDs, keyed by vpc_name |
| `cen_tr_attachment_ids` | Map of CEN transit router attachment IDs, keyed by vpc_name (null if attachment is not enabled) |

## Notes

- All VPCs share the same CEN instance, Transit Router, and route table configuration
- When `cen_attachment_enabled` is `true`, you must provide `cen_instance_id`, `cen_tr_id`, and `cen_tr_route_table_id`
- **Cross-account attachment**: When CEN and VPC are in different accounts, you must set `create_cen_instance_grant = true` to create the grant authorization. When they are in the same account, set it to `false`. 
- Vswitches with `purpose="TR"` are automatically used for Transit Router attachment
- Each VPC that has CEN attachment enabled must have at least 2 vswitches with `purpose="TR"`
- VPCs are created using `for_each`, so each VPC name must be unique

