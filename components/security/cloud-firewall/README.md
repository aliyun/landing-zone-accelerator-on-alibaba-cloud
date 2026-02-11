<div align="right">

**English** | [中文](README-CN.md)

</div>

# Cloud Firewall Component

This component creates and manages Alibaba Cloud Cloud Firewall instance, member account management, and internet control policies.

## Features

- Creates Cloud Firewall instance
- Manages member accounts for centralized firewall management
- Configures internet control policies
- Creates VPC CEN TR Firewalls (one firewall per transit router)
- Creates NAT Gateway Firewalls
- Creates NAT Gateway Firewall Control Policies
- Supports file-based and inline configuration
- File configuration takes precedence over inline configuration (if file path is provided, inline configuration is ignored)
- Creates VPC firewall control policies

## Important Notes

**⚠️ Payment Mode Limitation**: This component supports PayAsYouGo (按量付费) and Subscription (包年包月) version 1.0 billing modes. Subscription version 2.0 is not supported.

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
| [alicloud_cloud_firewall_instance.main](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_instance) | resource | Cloud Firewall instance |
| [alicloud_cloud_firewall_instance_member.members](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_instance_member) | resource | Member accounts |
| [alicloud_cloud_firewall_address_book.address_books](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_address_book) | resource | Address books |
| [alicloud_cloud_firewall_control_policy.internet](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_control_policy) | resource | Internet control policies |
| [alicloud_cloud_firewall_control_policy_order.in](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_control_policy_order) | resource | Priority order for inbound policies |
| [alicloud_cloud_firewall_control_policy_order.out](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_control_policy_order) | resource | Priority order for outbound policies |
| [alicloud_cloud_firewall_policy_advanced_config.main](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_policy_advanced_config) | resource | Advanced policy settings |
| [alicloud_cloud_firewall_vpc_cen_tr_firewall.vpc_firewalls](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_vpc_cen_tr_firewall) | resource | VPC CEN TR Firewalls (one firewall per transit router) |
| [alicloud_cloud_firewall_nat_firewall.nat_firewalls](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_nat_firewall) | resource | NAT Gateway Firewalls |
| [alicloud_cloud_firewall_nat_firewall_control_policy.nat_policies](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_nat_firewall_control_policy) | resource | NAT Gateway Firewall Control Policies |

## Usage

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  create_cloud_firewall_instance = true
  cloud_firewall_instance_type   = "premium_version"
  cloud_firewall_bandwidth       = 100
  cloud_firewall_payment_type    = "Subscription"
  cloud_firewall_period          = 12

  member_account_ids = [
    "123456789012",
    "234567890123"
  ]

  internet_control_policies = [
    {
      description           = "Allow HTTP from internet"
      source                = "0.0.0.0/0"
      destination           = "10.0.1.0/24"
      proto                 = "TCP"
      dest_port             = "80"
      acl_action            = "accept"
      direction             = "in"
      source_type           = "net"
      destination_type      = "net"
      application_name_list = ["HTTP"]
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `create_cloud_firewall_instance` | Whether to create a cloud firewall instance | `bool` | `true` | No | - |
| `cloud_firewall_instance_type` | The type of the cloud firewall instance | `string` | `"premium"` | No | Valid instance type |
| `cloud_firewall_bandwidth` | The bandwidth of the cloud firewall instance | `number` | `100` | No | - |
| `cloud_firewall_payment_type` | The payment type of the cloud firewall instance. Valid values: PayAsYouGo, Subscription (version 1.0 only, version 2.0 not supported) | `string` | `"PayAsYouGo"` | No | - |
| `cloud_firewall_period` | The prepaid period. Valid values: 1, 3, 6, 12, 24, 36. Required if payment_type is set to Subscription | `number` | `null` | No | - |
| `cloud_firewall_renewal_duration` | Auto-Renewal Duration. Valid values: 1, 2, 3, 6, 12. Required when renewal_status is AutoRenewal and payment_type is Subscription | `number` | `null` | No | - |
| `cloud_firewall_renewal_duration_unit` | Auto-Renewal Cycle Unit. Valid values: Month, Year | `string` | `null` | No | - |
| `cloud_firewall_renewal_status` | Whether to renew an instance automatically or not. Valid values: AutoRenewal, ManualRenewal. Default: ManualRenewal. Only takes effect when payment_type is Subscription | `string` | `"ManualRenewal"` | No | - |
| `cloud_firewall_modify_type` | The type of modification. Valid values: Upgrade, Downgrade. Required when executing an update operation | `string` | `null` | No | - |
| `cloud_firewall_cfw_log` | Whether to use log audit. Valid values: true, false. When payment_type is PayAsYouGo, cfw_log can only be set to true | `bool` | `null` | No | - |
| `cloud_firewall_cfw_log_storage` | The log storage capacity. When payment_type is PayAsYouGo or cfw_log is false, this will be ignored | `number` | `null` | No | - |
| `cloud_firewall_ip_number` | The number of public IPs that can be protected. Valid values: 20 to 4000 | `number` | `null` | No | See notes below |
| `member_account_ids` | List of member account IDs to be managed | `list(string)` | `[]` | No | - |
| `member_account_id_file_path` | File path to member account configuration file | `string` | `null` | No | Supports .json, .yaml, .yml |
| `internet_control_policies` | List of internet control policies | `list(object)` | `[]` | No | Valid policy configuration. Ignored if file paths are provided |
| `internet_control_policy_in_file_path` | File path to inbound (in) internet control policy configuration file (JSON/YAML). The file must contain an array of policy objects. If provided, inline `internet_control_policies` with direction="in" are ignored | `string` | `null` | No | Supports .json, .yaml, .yml. Must be array format |
| `internet_control_policy_out_file_path` | File path to outbound (out) internet control policy configuration file (JSON/YAML). The file must contain an array of policy objects. If provided, inline `internet_control_policies` with direction="out" are ignored | `string` | `null` | No | Supports .json, .yaml, .yml. Must be array format |
| `internet_switch` | Access control policy strict mode. Valid values: on, off | `string` | `null` | No | - |
| `address_books` | List of address books for the cloud firewall | `list(object)` | `[]` | No | See address_books object below |
| `vpc_cen_tr_firewalls` | List of VPC CEN TR Firewall configurations. One firewall per transit router | `list(object)` | `[]` | No | See vpc_cen_tr_firewalls object below |
| `vpc_firewall_control_policies` | List of VPC firewall control policy configurations grouped by cen_id. Each configuration includes cen_id, control_policies (inline), and optional control_policy_file_path (file config). File config takes precedence over inline config | `list(object)` | `[]` | No | See vpc_firewall_control_policies object below |
| `nat_firewalls` | List of NAT Gateway Firewall configurations | `list(object)` | `[]` | No | See nat_firewalls object below |
| `nat_firewall_control_policies` | List of NAT Gateway firewall control policy configurations grouped by nat_gateway_id. Each configuration includes nat_gateway_id, control_policies (inline), and optional control_policy_file_path (file config). File config takes precedence over inline config. Direction is fixed to 'out' and new_order is fixed to 1 | `list(object)` | `[]` | No | See nat_firewall_control_policies object below |

### address_books Object

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `group_name` | The name of the Address Book | `string` | Yes | - |
| `group_type` | The type of the Address Book. Valid values: port, ackLabel, ipv6, ip, domain, ackNamespace, tag | `string` | Yes | - |
| `description` | The description of the Address Book | `string` | Yes | - |
| `auto_add_tag_ecs` | Whether you want to automatically add new matching tags of the ECS IP address to the Address Book. Valid values: 0, 1 | `number` | No | - |
| `tag_relation` | The logical relation among the ECS tags that to be matched. Valid values: and, or | `string` | No | `"and"` |
| `lang` | The language of the content within the request and response. Valid values: zh, en | `string` | No | - |
| `address_list` | The list of addresses | `list(string)` | No | `[]` |
| `ecs_tags` | A list of ECS tags | `list(object)` | No | `[]` |

#### ecs_tags Object

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `tag_key` | The key of ECS tag that to be matched | `string` | No | - |
| `tag_value` | The value of ECS tag that to be matched | `string` | No | - |

### vpc_cen_tr_firewalls Object

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `transit_router_id` | The ID of the transit router instance | `string` | Yes | - |
| `cen_id` | The ID of the CEN instance | `string` | Yes | - |
| `firewall_name` | The name of Cloud Firewall | `string` | Yes | - |
| `region_no` | The region ID of the transit router instance | `string` | Yes | - |
| `route_mode` | The routing pattern. Valid values: managed (automatic mode), manual (manual mode) | `string` | Yes | - |
| `firewall_vpc_cidr` | Required in automatic mode, the CIDR of firewall VPC | `string` | Yes | - |
| `firewall_subnet_cidr` | Required in automatic mode, the CIDR of subnet used to store the firewall ENI in the firewall VPC | `string` | Yes | - |
| `tr_attachment_master_cidr` | Required in automatic mode, the primary CIDR of network used to connect to the TR in the firewall VPC | `string` | Yes | - |
| `tr_attachment_slave_cidr` | Required in automatic mode, the secondary CIDR of the subnet in the firewall VPC used to connect to TR | `string` | Yes | - |
| `firewall_description` | Firewall description | `string` | No | - |
| `tr_attachment_master_zone` | The primary zone of the switch | `string` | No | - |
| `tr_attachment_slave_zone` | Switch standby area | `string` | No | - |

### vpc_firewall_control_policies Object

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `cen_id` | The ID of the CEN instance (vpc_firewall_id). When the VPC firewall protects traffic between two VPCs connected through the cloud enterprise network, the policy group ID uses the cloud enterprise network instance ID | `string` | Yes | - |
| `control_policies` | List of inline control policies for this CEN. Ignored if control_policy_file_path is provided | `list(object)` | No | `[]` | See control_policies object below |
| `control_policy_file_path` | File path to control policy configuration file (JSON/YAML) for this CEN. The file must contain an array of policy objects. File config takes precedence over control_policies | `string` | No | - | Supports .json, .yaml, .yml. Must be array format |

#### control_policies Object

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `description` | Access control over VPC firewalls description of the strategy information | `string` | Yes | - |
| `source` | Access control over VPC firewalls strategy in the source address | `string` | Yes | - |
| `source_type` | The type of the source address in the access control policy. Valid values: net, group | `string` | Yes | - |
| `destination` | The destination address in the access control policy. If destination_type is set to net, the value must be a CIDR block. If destination_type is set to group, the value must be an address book. If destination_type is set to domain, the value must be a domain name | `string` | Yes | - |
| `destination_type` | The type of the destination address in the access control policy. Valid values: net, group, domain | `string` | Yes | - |
| `proto` | The type of the protocol in the access control policy. Valid values: ANY, TCP, UDP, ICMP | `string` | Yes | - |
| `acl_action` | The action that Cloud Firewall performs on the traffic. Valid values: accept, drop, log | `string` | Yes | - |
| `dest_port` | The destination port in the access control policy. Required if dest_port_type is set to port | `string` | No | - |
| `dest_port_group` | Access control policy in the access traffic of the destination port address book name. Required if dest_port_type is set to group | `string` | No | - |
| `dest_port_type` | The type of the destination port in the access control policy. Valid values: port, group | `string` | No | - |
| `application_name_list` | The list of application types that the access control policy supports. Valid values: ANY, HTTP, HTTPS, MQTT, Memcache, MongoDB, MySQL, RDP, Redis, SMTP, SMTPS, SSH, SSL, VNC. If proto is TCP, can be any valid value. If proto is UDP, ICMP, or ANY, can only be ["ANY"] | `list(string)` | Yes | - |
| `release` | The enabled status of the access control policy. The policy is enabled by default after it is created. Valid values: true (enable), false (disable) | `bool` | No | - |
| `member_uid` | The UID of the member account of the current Alibaba cloud account | `string` | No | - |
| `domain_resolve_type` | The domain name resolution method for the access control policy. Valid values: FQDN, DNS, FQDN_AND_DNS. Available since v1.267.0 | `string` | No | - |
| `repeat_type` | The recurrence type for the policy validity period. Valid values: Permanent, None, Daily, Weekly, Monthly. Available since v1.267.0 | `string` | No | `"Permanent"` |
| `repeat_days` | The days of the week or month on which the policy is recurrently active. If repeat_type is Weekly, valid values: 0 to 6. If repeat_type is Monthly, valid values: 1 to 31. Available since v1.267.0 | `list(number)` | No | - |
| `repeat_end_time` | The recurring end time of the policy validity period. Available since v1.267.0 | `string` | No | - |
| `repeat_start_time` | The recurring start time of the policy validity period. Available since v1.267.0 | `string` | No | - |
| `start_time` | The start time of the policy validity period. UNIX timestamp in seconds. Must be on the hour or on the half hour. Available since v1.267.0 | `number` | No | - |
| `end_time` | The end time of the policy validity period. UNIX timestamp in seconds. Must be on the hour or on the half hour, and at least 30 minutes later than start_time. Available since v1.267.0 | `number` | No | - |
| `lang` | The language of the content within the request and response. Valid values: zh, en | `string` | No | `"zh"` |

**Note:** The `order` field is fixed to 1 for all policies due to Terraform's parallel execution model. Since Terraform creates resources in parallel, it's impossible to guarantee the order of policy creation matches the array index. Setting order to 1 ensures newly created policies have the highest priority (smaller order value = higher priority). If you need specific ordering, manage policies outside of Terraform or use separate sequential apply operations.

### internet_control_policies Object

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `description` | Rule description | `string` | Yes | - |
| `source` | Source address in the access control policy | `string` | Yes | - |
| `destination` | Destination address in the access control policy | `string` | Yes | - |
| `proto` | The protocol type supported by the access control policy. Valid values: ANY, TCP, UDP, ICMP | `string` | Yes | - |
| `dest_port` | The destination port. Required if dest_port_type is set to port | `string` | No | - |
| `acl_action` | The action that Cloud Firewall performs on the traffic. Valid values: accept, drop, log | `string` | Yes | - |
| `direction` | The direction of the traffic to which the access control policy applies. Valid values: in, out | `string` | Yes | - |
| `source_type` | The type of the source address. Valid values: net, group, location | `string` | Yes | - |
| `destination_type` | The type of the destination address. Valid values: net, group, domain, location | `string` | Yes | - |
| `application_name_list` | The list of application types supported by the access control policy. Valid values: ANY, HTTP, HTTPS, MQTT, Memcache, MongoDB, MySQL, RDP, Redis, SMTP, SMTPS, SSH, SSL, VNC. If proto is TCP, can be any valid value. If proto is UDP, ICMP, or ANY, can only be ANY | `list(string)` | Yes | - |
| `dest_port_group` | The name of the destination port address book. Required if dest_port_type is set to group | `string` | No | - |
| `dest_port_type` | The type of the destination port. Valid values: port, group | `string` | No | - |
| `ip_version` | The IP version supported by the access control policy. Valid values: 4 (IPv4), 6 (IPv6) | `number` | No | `4` |
| `domain_resolve_type` | The domain name resolution method. Valid values: FQDN, DNS, FQDN_AND_DNS | `string` | No | - |
| `start_time` | The time when the access control policy starts taking effect. UNIX timestamp in seconds. Must be on the hour or on the half hour | `number` | No | - |
| `end_time` | The time when the access control policy stops taking effect. UNIX timestamp in seconds. Must be on the hour or on the half hour, and at least 30 minutes later than start_time. Required if repeat_type is None, Daily, Weekly, or Monthly | `number` | No | - |
| `repeat_type` | The repeat type for the access control policy | `string` | No | `"Permanent"` |
| `repeat_start_time` | The start time for the repeat period | `string` | No | - |
| `repeat_end_time` | The end time for the repeat period | `string` | No | - |
| `repeat_days` | The days of the week for the repeat period | `list(number)` | No | - |
| `release` | Whether to release the policy | `bool` | No | - |
| `lang` | The language of the content within the request and response. Valid values: zh, en | `string` | No | `"zh"` |

### nat_firewalls Object

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `nat_gateway_id` | The ID of the NAT gateway | `string` | Yes | - |
| `proxy_name` | The name of the NAT firewall | `string` | Yes | - |
| `region_no` | The region where the NAT firewall is located | `string` | Yes | - |
| `vpc_id` | The ID of the VPC instance | `string` | Yes | - |
| `nat_route_entry_list` | List of routes to be switched by the NAT gateway | `list(object)` | Yes | - | See nat_route_entry_list object below |
| `firewall_switch` | Safety protection switch. Valid values: open, close | `string` | No | - |
| `lang` | The language of the content within the request and response. Valid values: zh, en | `string` | No | - |
| `strict_mode` | Whether strict mode is enabled. Valid values: 0 (Disable), 1 (Enable) | `number` | No | - |
| `vswitch_auto` | Whether to use switch automatic mode. Valid values: true (automatic mode), false (manual mode) | `bool` | No | - |
| `vswitch_id` | The switch ID. Required if vswitch_auto is false (manual mode) | `string` | No | - |
| `vswitch_cidr` | The network segment of the virtual switch. Required if vswitch_auto is true (automatic mode) | `string` | No | - |

#### nat_route_entry_list Object

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `destination_cidr` | The destination network segment of the default route | `string` | No | `"0.0.0.0/0"` |
| `nexthop_id` | The next hop address of the original NAT gateway. If not provided, uses nat_gateway_id | `string` | No | Uses `nat_gateway_id` |
| `route_table_id` | The route table where the default route of the NAT gateway is located | `string` | Yes | - |

**Note:** 
- `nexthop_type` is automatically set to `"NatGateway"` and cannot be changed
- If `nexthop_id` is not provided or is null, it will automatically use the `nat_gateway_id` from the parent firewall configuration
- If `destination_cidr` is not provided or is null, it will default to `"0.0.0.0/0"`

## Outputs

| Name | Description |
|------|-------------|
| `cloud_firewall_instance_id` | The ID of the cloud firewall instance |
| `cloud_firewall_instance_status` | The status of the cloud firewall instance |
| `member_account_ids` | The list of member account IDs managed by the cloud firewall |
| `internet_control_policy_count` | The number of internet control policies created |
| `internet_control_policies` | List of internet control policies with their ACL UUIDs |
| `address_books` | Map of address books created, keyed by group_name |
| `vpc_cen_tr_firewalls` | Map of VPC CEN TR Firewalls created, keyed by transit_router_id |
| `vpc_firewall_control_policies` | List of VPC firewall control policies created with their details including acl_uuid, application_id, source_group_cidrs, destination_group_cidrs, etc. |
| `nat_firewalls` | Map of NAT Gateway Firewalls created, keyed by nat_gateway_id |
| `nat_firewall_control_policies` | List of NAT Gateway firewall control policies created with their details including acl_uuid |

## Examples

### Basic Cloud Firewall Instance

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  create_cloud_firewall_instance = true
  cloud_firewall_instance_type   = "premium_version"
  cloud_firewall_bandwidth       = 100
  cloud_firewall_payment_type    = "Subscription"
  cloud_firewall_period          = 12
}
```

### With Member Accounts

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  member_account_ids = [
    "123456789012",
    "234567890123"
  ]
}
```

### With File Configuration

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  member_account_id_file_path = "./member_accounts/accounts.json"
  
  # Inbound policies file (must be an array)
  internet_control_policy_in_file_path = "./policies/inbound.json"
  
  # Outbound policies file (must be an array)
  internet_control_policy_out_file_path = "./policies/outbound.json"
}
```

Example `inbound.json`:
```json
[
  {
    "description": "Allow HTTP from internet",
    "source": "0.0.0.0/0",
    "destination": "10.0.1.0/24",
    "proto": "TCP",
    "dest_port": "80/80",
    "acl_action": "accept",
    "direction": "in",
    "source_type": "net",
    "destination_type": "net",
    "application_name_list": ["HTTP"]
  },
  {
    "description": "Allow HTTPS from internet",
    "source": "0.0.0.0/0",
    "destination": "10.0.1.0/24",
    "proto": "TCP",
    "dest_port": "443/443",
    "acl_action": "accept",
    "direction": "in",
    "source_type": "net",
    "destination_type": "net",
    "application_name_list": ["HTTPS"]
  }
]
```

**Note**: If `direction` field is not present in the file, it will be automatically set to "in" for inbound file and "out" for outbound file. If `direction` field exists but doesn't match the file type (e.g., "out" in inbound file), that rule will be filtered out.

### Internet Control Policies

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  internet_control_policies = [
    {
      description           = "Allow HTTPS from internet"
      source                = "0.0.0.0/0"
      destination           = "10.0.1.0/24"
      proto                 = "TCP"
      dest_port             = "443"
      acl_action            = "accept"
      direction             = "in"
      source_type           = "net"
      destination_type      = "net"
      application_name_list = ["HTTPS"]
    },
    {
      description           = "Block SSH from internet"
      source                = "0.0.0.0/0"
      destination           = "10.0.1.0/24"
      proto                 = "TCP"
      dest_port             = "22"
      acl_action            = "drop"
      direction             = "in"
      source_type           = "net"
      destination_type      = "net"
      application_name_list = ["SSH"]
    }
  ]
}
```

### VPC CEN TR Firewall

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  vpc_cen_tr_firewalls = [
    {
      transit_router_id         = "tr-uf6e6h5vv5eigxxxxxx"
      cen_id                    = "cen-jhwbspfj5lnxxxxxxxx"
      firewall_name             = "vpc-firewall-1"
      region_no                 = "cn-hangzhou"
      route_mode                = "managed"
      firewall_vpc_cidr         = "10.0.0.0/16"
      firewall_subnet_cidr      = "10.0.1.0/24"
      tr_attachment_master_cidr = "10.0.2.0/24"
      tr_attachment_slave_cidr = "10.0.3.0/24"
      firewall_description      = "VPC Firewall for TR 1"
      tr_attachment_master_zone = "cn-hangzhou-h"
      tr_attachment_slave_zone  = "cn-hangzhou-i"
    },
    {
      transit_router_id         = "tr-2zebnpl3f8z7i3xxxxxx"
      cen_id                    = "cen-jhwbspfj5lnxxxxxxxx"
      firewall_name             = "vpc-firewall-2"
      region_no                 = "cn-beijing"
      route_mode                = "managed"
      firewall_vpc_cidr         = "10.1.0.0/16"
      firewall_subnet_cidr      = "10.1.1.0/24"
      tr_attachment_master_cidr = "10.1.2.0/24"
      tr_attachment_slave_cidr = "10.1.3.0/24"
    }
  ]
}
```

### VPC Firewall Control Policy

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  # Inline configuration grouped by cen_id
  vpc_firewall_control_policies = [
    {
      cen_id = "cen-jhwbspfj5lnxxxxxxxx"
      control_policies = [
        {
          description           = "Allow HTTPS traffic"
          source                = "10.0.0.0/8"
          destination           = "10.1.0.0/16"
          proto                 = "TCP"
          dest_port             = "443/443"
          acl_action            = "accept"
          source_type           = "net"
          destination_type      = "net"
          application_name_list = ["HTTPS"]
          lang                  = "zh"
        },
        {
          description           = "Block SSH from specific network"
          source                = "203.0.113.0/24"
          destination           = "10.1.0.0/16"
          proto                 = "TCP"
          dest_port             = "22/22"
          acl_action            = "drop"
          source_type           = "net"
          destination_type      = "net"
          application_name_list = ["SSH"]
          lang                  = "zh"
        }
      ]
    },
    {
      cen_id = "cen-yyy"
      control_policy_file_path = "./configs/cen-yyy-policies.json"
    }
  ]
}
```

Or use file configuration for a specific CEN:

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  vpc_firewall_control_policies = [
    {
      cen_id                   = "cen-jhwbspfj5lnxxxxxxxx"
      control_policy_file_path  = "./configs/cen-xxx-policies.json"
    }
  ]
}
```

Example JSON file (`cen-xxx-policies.json`):

```json
[
  {
    "description": "Allow HTTPS traffic",
    "source": "10.0.0.0/8",
    "destination": "10.1.0.0/16",
    "proto": "TCP",
    "dest_port": "443/443",
    "acl_action": "accept",
    "source_type": "net",
    "destination_type": "net",
    "application_name_list": ["HTTPS"],
    "lang": "zh"
  },
  {
    "description": "Block SSH from specific network",
    "source": "203.0.113.0/24",
    "destination": "10.1.0.0/16",
    "proto": "TCP",
    "dest_port": "22/22",
    "acl_action": "drop",
    "source_type": "net",
    "destination_type": "net",
    "application_name_list": ["SSH"],
    "lang": "zh"
  }
]
```

**Note:** 
- The `order` field is automatically set based on the array index within each cen_id (starting from 1). Policies are created in the order they appear in the array for each CEN.
- File configuration (`control_policy_file_path`) takes precedence over inline configuration (`control_policies`) for the same cen_id.
- Each cen_id can have its own file or inline policies, or both (file takes precedence).

### NAT Gateway Firewall

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  # ... other configurations ...

  nat_firewalls = [
    {
      nat_gateway_id = "ngw-uf6hg6eaaqz70xxxxxx"
      proxy_name     = "nat-firewall-1"
      region_no      = "cn-shanghai"
      vpc_id         = "vpc-uf6v10ktt3tnxxxxxxxx"
      nat_route_entry_list = [
        {
          route_table_id   = "vtb-uf6i7jiaadomxxxxxx"
          destination_cidr = "0.0.0.0/0"
          nexthop_id       = "ngw-uf6hg6eaaqz70xxxxxx"
        }
      ]
      firewall_switch = "open"
      vswitch_auto    = true
      vswitch_cidr    = "172.16.5.0/24"
    }
  ]
}
```

**Note:**
- Each NAT Gateway can have one firewall. The firewall is keyed by `nat_gateway_id`
- In `nat_route_entry_list`, `nexthop_type` is automatically set to `"NatGateway"` and cannot be changed
- If `nexthop_id` is not provided in a route entry, it will automatically use the `nat_gateway_id` from the parent firewall configuration
- If `destination_cidr` is not provided in a route entry, it will default to `"0.0.0.0/0"`
- If `vswitch_auto` is `true` (automatic mode), `vswitch_cidr` is required
- If `vswitch_auto` is `false` (manual mode), `vswitch_id` is required

### NAT Gateway Firewall Control Policy

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  # ... other configurations ...

  nat_firewall_control_policies = [
    {
      nat_gateway_id = "ngw-uf6hg6eaaqz70xxxxxx"
      control_policies = [
        {
          description           = "Allow HTTPS traffic"
          source                = "10.0.0.0/8"
          destination           = "0.0.0.0/0"
          proto                 = "TCP"
          dest_port             = "443/443"
          acl_action            = "accept"
          source_type           = "net"
          destination_type      = "net"
          application_name_list = ["HTTPS"]
          ip_version            = 4
        }
      ]
    }
  ]
}
```

Or use file configuration:

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  nat_firewall_control_policies = [
    {
      nat_gateway_id            = "ngw-uf6hg6eaaqz70xxxxxx"
      control_policy_file_path  = "./configs/nat-gw-xxx-policies.json"
    }
  ]
}
```

**Note:**
- `direction` is automatically set to `"out"` and cannot be changed for NAT Gateway firewall control policies
- `new_order` is fixed to 1 for all policies due to Terraform's parallel execution model. This ensures newly created policies have the highest priority
- File configuration (`control_policy_file_path`) takes precedence over inline configuration (`control_policies`) for the same nat_gateway_id
- Each nat_gateway_id can have its own file or inline policies, or both (file takes precedence)

## Notes

- **Payment Mode**: This component supports PayAsYouGo (按量付费) and Subscription (包年包月) version 1.0 billing modes. Subscription version 2.0 is not supported.
- Cloud Firewall instance must be created before adding member accounts or configuring policies
- Member accounts are added to the firewall for centralized management
- Internet control policies allow fine-grained control over traffic
- **File Configuration Priority**: If file paths (`internet_control_policy_in_file_path` or `internet_control_policy_out_file_path`) are provided, inline `internet_control_policies` are ignored for the corresponding direction
- **File Format**: Policy configuration files must contain an array of policy objects (not a single object)
- **Direction Field**: 
  - If `direction` field is missing in the file, it will be automatically set ("in" for inbound file, "out" for outbound file)
  - If `direction` field exists but doesn't match the file type (e.g., "out" in inbound file), that rule will be filtered out
- **Policy Priority**: Policy priority order is automatically set based on array index (starting from 1), separately for inbound and outbound policies
- **VPC Firewall Control Policy Order**: The `order` field is fixed to 1 for all VPC firewall control policies due to Terraform's parallel execution model. This ensures newly created policies have the highest priority. If specific ordering is required, manage policies outside of Terraform or use separate sequential apply operations.
- Policy uniqueness is determined by description, source, destination, dest_port, and direction
- **VPC CEN TR Firewall**: One firewall is created per transit router. Each firewall configuration must have a unique `transit_router_id`. VPC firewalls depend on member accounts being added to the Cloud Firewall instance
- **VPC Firewall Control Policy**: 
  - Policies are grouped by `cen_id`. Each configuration includes `cen_id`, optional `control_policies` (inline), and optional `control_policy_file_path` (file config)
  - File configuration (`control_policy_file_path`) takes precedence over inline configuration (`control_policies`) for the same cen_id
  - The `order` field is fixed to 1 for all policies due to Terraform's parallel execution limitations. This ensures newly created policies have the highest priority. If specific ordering is required, manage policies outside of Terraform
  - File configuration must contain an array of policy objects (without cen_id, as it's specified in the configuration)
- **NAT Gateway Firewall**: 
  - One firewall can be created per NAT Gateway. The firewall is keyed by `nat_gateway_id`
  - In `nat_route_entry_list`, `nexthop_type` is automatically set to `"NatGateway"` and cannot be changed
  - If `nexthop_id` is not provided in a route entry, it will automatically use the `nat_gateway_id` from the parent firewall configuration
  - If `destination_cidr` is not provided in a route entry, it will default to `"0.0.0.0/0"`
  - If `vswitch_auto` is `true` (automatic mode), `vswitch_cidr` is required
  - If `vswitch_auto` is `false` (manual mode), `vswitch_id` is required
- **NAT Gateway Firewall Control Policy**: 
  - Policies are grouped by `nat_gateway_id`. Each configuration includes `nat_gateway_id`, optional `control_policies` (inline), and optional `control_policy_file_path` (file config)
  - File configuration (`control_policy_file_path`) takes precedence over inline configuration (`control_policies`) for the same nat_gateway_id
  - `direction` is automatically set to `"out"` and cannot be changed
  - `new_order` is fixed to 1 for all policies due to Terraform's parallel execution limitations. This ensures newly created policies have the highest priority. If specific ordering is required, manage policies outside of Terraform
  - File configuration must contain an array of policy objects (without nat_gateway_id, as it's specified in the configuration)

### ip_number Parameter

The `ip_number` parameter specifies the number of public IPs that can be protected:
- **premium_version**: Valid range [60, 1000], default value: 20
- **enterprise_version**: Valid range [60, 1000], default value: 50
- **ultimate_version**: Valid range [400, 4000], default value: 400
