<div align="right">

**English** | [中文](README-CN.md)

</div>

# CEN Route Map Component

This component creates and manages CEN (Cloud Enterprise Network) route maps (routing policies) with flexible configuration options.

## Features

- Creates multiple CEN route map policies
- Supports three configuration methods:
  - Direct configuration via Terraform variables
  - Load from individual YAML/JSON files
  - Load from a directory of YAML/JSON files
- Supports both match conditions and route actions
- Automatic policy normalization and validation
- Flexible priority-based routing control

## Important Note

Route maps are applied based on priority (1-100, lower number = higher priority). When a route matches all conditions in a policy, the policy action (Permit/Deny) is executed. Routes that don't match all conditions are allowed by default.

For more information, see:
- [Terraform Resource Documentation](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_route_map)
- [Alibaba Cloud API Documentation](https://www.alibabacloud.com/help/zh/cen/developer-reference/api-cbn-2017-09-12-createcenroutemap)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.120.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.120.0 |

## Modules

No modules.

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_cen_route_map.route_map](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_route_map) | resource | CEN route map (routing policy) |

## Usage

### Method 1: Direct Configuration

```hcl
module "cen_route_map" {
  source = "./components/network/cen-route-map"

  cen_id                        = "cen-xxxxxxxxxxxxx"
  tr_region_id                  = "cn-shanghai"
  transit_router_route_table_id = null # null for system/default route table

  route_policies = [
    {
      transmit_direction = "RegionIn"
      priority           = 10
      map_result         = "Permit"
      description        = "Allow BGP routes from VPN"
      
      # Match conditions
      source_instance_ids         = ["vpn-xxxxxxxxxxxxx"]
      source_child_instance_types = ["VPN"]
      route_types                 = ["BGP"]
      
      # Actions
      preference = 100
    },
    {
      transmit_direction = "RegionOut"
      priority           = 20
      map_result         = "Permit"
      description        = "Set preference for routes to VPN"
      
      destination_instance_ids         = ["vpn-xxxxxxxxxxxxx"]
      destination_child_instance_types = ["VPN"]
      prepend_as_path                  = ["65001", "65001"]
      preference                       = 110
    }
  ]
}
```

### Method 2: Load from Files

```hcl
module "cen_route_map" {
  source = "./components/network/cen-route-map"

  cen_id                        = "cen-xxxxxxxxxxxxx"
  tr_region_id                  = "cn-shanghai"
  transit_router_route_table_id = null
  
  policy_file_paths = ["./policies/vpn-policies.yaml"]
}
```

**Example policy file (YAML) - Array Format:**

```yaml
# vpn-policies.yaml
# Note: tr_region_id and transit_router_route_table_id are defined in Terraform config
# This file only contains policy definitions, making it reusable
# Files must contain an array of policy objects
- transmit_direction: RegionIn
  priority: 10
  map_result: Permit
  description: Allow BGP routes from VPN
  source_instance_ids:
    - vpn-xxxxxxxxxxxxx
  route_types:
    - BGP
  preference: 100

- transmit_direction: RegionOut
  priority: 20
  map_result: Permit
  description: Set preference for routes to VPN
  destination_instance_ids:
    - vpn-xxxxxxxxxxxxx
  preference: 110
```

### Method 3: Load from Directory

```hcl
module "cen_route_map" {
  source = "./components/network/cen-route-map"

  cen_id                        = "cen-xxxxxxxxxxxxx"
  tr_region_id                  = "cn-shanghai"
  transit_router_route_table_id = null
  
  policy_dir_paths = ["./route-policies"]
}
```

All `.json`, `.yaml`, and `.yml` files in the directories and their subdirectories will be processed. You can specify multiple directories:

```hcl
module "cen_route_map" {
  source = "./components/network/cen-route-map"

  cen_id                        = "cen-xxxxxxxxxxxxx"
  tr_region_id                  = "cn-shanghai"
  transit_router_route_table_id = null
  
  policy_dir_paths = [
    "./route-policies/shared",
    "./route-policies/region-specific"
  ]
}
```

### Method 4: Combined Configuration

```hcl
module "cen_route_map" {
  source = "./components/network/cen-route-map"

  cen_id                        = "cen-xxxxxxxxxxxxx"
  tr_region_id                  = "cn-shanghai"
  transit_router_route_table_id = null
  
  # Direct policies
  route_policies = [
    {
      transmit_direction = "RegionIn"
      priority           = 10
      map_result         = "Permit"
      description        = "Direct policy"
    }
  ]
  
  # Load additional policies from files
  policy_file_paths = ["./policies/additional-policies.yaml"]
  
  # Load even more policies from directory
  policy_dir_paths = ["./route-policies"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `cen_id` | The ID of the CEN instance | `string` | - | Yes |
| `tr_region_id` | Transit Router region ID | `string` | - | Yes |
| `transit_router_route_table_id` | Route table ID. If `null`, uses the default system route table | `string` | `null` | No |
| `route_policies` | List of route policies (direct configuration) | `list(object)` | `[]` | No |
| `policy_file_paths` | List of route policy file paths (YAML/JSON). Each element should be a file path | `list(string)` | `[]` | No |
| `policy_dir_paths` | List of directory paths containing route policy files (YAML/JSON). Files must contain an array of policy objects | `list(string)` | `[]` | No |

### Policy Object Structure (within `route_policies`)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `transmit_direction` | `string` | Yes | Policy direction: `RegionIn` (into region) or `RegionOut` (out of region) |
| `priority` | `number` | Yes | Priority (1-100, lower = higher priority) |
| `map_result` | `string` | Yes | Policy action: `Permit` or `Deny` |
| `description` | `string` | No | Policy description (1-256 chars) |
| `next_priority` | `number` | No | Next policy priority to evaluate (only for Permit) |

#### Match Conditions

| Field | Type | Description |
|-------|------|-------------|
| `cidr_match_mode` | `string` | CIDR match mode: `Include` (fuzzy) or `Complete` (exact) |
| `as_path_match_mode` | `string` | AS Path match mode: `Include` or `Complete` |
| `community_match_mode` | `string` | Community match mode: `Include` or `Complete` |
| `match_asns` | `list(string)` | List of AS numbers to match (max 32) |
| `match_community_set` | `list(string)` | List of communities to match (max 32) |
| `route_types` | `list(string)` | Route types: `System`, `Custom`, `BGP` |
| `source_instance_ids` | `list(string)` | Source instance IDs (max 32) |
| `source_instance_ids_reverse_match` | `bool` | Reverse match for source instances |
| `source_route_table_ids` | `list(string)` | Source route table IDs (max 32) |
| `source_region_ids` | `list(string)` | Source region IDs (max 32) |
| `source_child_instance_types` | `list(string)` | Source instance types: `VPC`, `VBR`, `CCN`, `VPN` |
| `destination_instance_ids` | `list(string)` | Destination instance IDs (max 32) |
| `destination_instance_ids_reverse_match` | `bool` | Reverse match for destination instances |
| `destination_route_table_ids` | `list(string)` | Destination route table IDs (max 32) |
| `destination_child_instance_types` | `list(string)` | Destination instance types: `VPC`, `VBR`, `CCN`, `VPN` |
| `destination_cidr_blocks` | `list(string)` | Destination CIDR blocks (max 32) |

#### Actions

| Field | Type | Description |
|-------|------|-------------|
| `community_operate_mode` | `string` | Community operation mode: `Additive` or `Replace` |
| `prepend_as_path` | `list(string)` | AS Path to prepend (max 32 AS numbers) |
| `preference` | `number` | Route preference/priority |
| `operate_community_set` | `list(string)` | Community values to add/replace (max 32) |

## Outputs

| Name | Description |
|------|-------------|
| `route_map_ids` | List of all route map IDs (`route_map_id`) |
| `route_maps` | List of all route map details, including `id`, `route_map_id`, region, direction, priority, status, etc. |

## Examples

### Example 1: VPN Route Filtering

```hcl
module "vpn_route_policy" {
  source = "./components/network/cen-route-map"

  cen_id                        = "cen-xxxxxxxxxxxxx"
  tr_region_id                  = "cn-shanghai"
  transit_router_route_table_id = null

  route_policies = [
    {
      transmit_direction = "RegionIn"
      priority           = 10
      map_result         = "Permit"
      description        = "Allow BGP routes from VPN with preference 100"
      
      source_instance_ids         = ["vpn-xxxxxxxxxxxxx"]
      source_child_instance_types = ["VPN"]
      route_types                 = ["BGP"]
      
      preference = 100
    }
  ]
}
```

### Example 2: Deny Specific CIDR Blocks

```hcl
module "deny_cidr_policy" {
  source = "./components/network/cen-route-map"

  cen_id                        = "cen-xxxxxxxxxxxxx"
  tr_region_id                  = "cn-shanghai"
  transit_router_route_table_id = null

  route_policies = [
    {
      transmit_direction = "RegionOut"
      priority           = 20
      map_result         = "Deny"
      description        = "Deny private IP ranges"
      
      destination_cidr_blocks = [
        "192.168.100.0/24",
        "10.10.10.0/24"
      ]
      cidr_match_mode = "Complete"
    }
  ]
}
```

### Example 3: AS Path Prepending with Route Table

```hcl
module "as_path_policy" {
  source = "./components/network/cen-route-map"

  cen_id                        = "cen-xxxxxxxxxxxxx"
  tr_region_id                  = "cn-shanghai"
  transit_router_route_table_id = "vtb-xxxxxxxxxxxxx"

  route_policies = [
    {
      transmit_direction = "RegionOut"
      priority           = 30
      map_result         = "Permit"
      description        = "Prepend AS path for routes to VPN"
      
      destination_instance_ids         = ["vpn-xxxxxxxxxxxxx"]
      destination_child_instance_types = ["VPN"]
      
      prepend_as_path = ["65001", "65001"]
    }
  ]
}
```

### Example 4: Load from YAML File

Create a file `route-policies/vpn-policies.yaml`:

```yaml
# Note: tr_region_id and transit_router_route_table_id are defined in Terraform config
- transmit_direction: RegionIn
  priority: 10
  map_result: Permit
  description: Allow VPN BGP routes
  source_instance_ids:
    - vpn-xxxxxxxxxxxxx
  source_child_instance_types:
    - VPN
  route_types:
    - BGP
  preference: 100

- transmit_direction: RegionOut
  priority: 20
  map_result: Permit
  description: Set preference for routes to VPN
  destination_instance_ids:
    - vpn-xxxxxxxxxxxxx
  preference: 110
```

Then use in Terraform:

```hcl
module "cen_route_map" {
  source = "./components/network/cen-route-map"

  cen_id                        = "cen-xxxxxxxxxxxxx"
  tr_region_id                  = "cn-shanghai"
  transit_router_route_table_id = null
  
  policy_file_paths = ["./route-policies/vpn-policies.yaml"]
}
```

### Example 5: Load from Directory

```hcl
module "cen_route_map" {
  source = "./components/network/cen-route-map"

  cen_id                        = "cen-xxxxxxxxxxxxx"
  tr_region_id                  = "cn-shanghai"
  transit_router_route_table_id = null
  
  policy_dir_paths = ["./route-policies"]
}
```

This will load all `.json`, `.yaml`, and `.yml` files from the `./route-policies` directory and its subdirectories.

## Notes

- Route maps are evaluated by priority (lower number = higher priority)
- For routes matching all conditions, the policy action (Permit/Deny) is applied
- Routes not matching all conditions are permitted by default
- When `map_result` is `Permit`, you can set `next_priority` to chain multiple policies
- Each policy must have a unique combination of `transmit_direction` and `priority` within the same route table
- If `transit_router_route_table_id` is not specified, the policy is associated with the default system route table
- Community values must follow RFC 1997 format (n:m where n and m are 1-65535)
- AS numbers must be 1-4294967295
- Description cannot start with `http://` or `https://`
- Maximum 32 items for list-based match conditions and actions

## Configuration File Format

Policy files should only contain policy definitions. The `tr_region_id` and `transit_router_route_table_id` are defined in the outer Terraform configuration, making policy files reusable across different route tables.

**Note:** Policy files must contain an array of policy objects. Single policy objects are not supported.

### YAML Format (Array of Policies)

```yaml
# policies.yaml
- transmit_direction: RegionIn
  priority: 10
  map_result: Permit
  description: Policy 1
  
- transmit_direction: RegionOut
  priority: 20
  map_result: Deny
  description: Policy 2
```

### JSON Format (Array of Policies)

```json
[
  {
    "transmit_direction": "RegionIn",
    "priority": 10,
    "map_result": "Permit",
    "description": "Policy 1"
  },
  {
    "transmit_direction": "RegionOut",
    "priority": 20,
    "map_result": "Deny",
    "description": "Policy 2"
  }
]
```

