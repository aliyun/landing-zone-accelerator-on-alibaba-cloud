provider "alicloud" {
  region = "cn-shanghai"
  assume_role {
    # Original example account ID in role_arn replaced for desensitization
    role_arn           = "acs:ram::<ACCOUNT_ID>:role/resourcedirectoryaccountaccessrole"
    session_name       = "landing-zone-accelerator"
    session_expiration = 3600
  }
}

module "cloud_firewall" {
  source = "../../../../components/security/cloud-firewall"

  # Cloud Firewall instance configuration
  # Note: Since Terraform does not support the Subscription 2.0 billing mode, if customers need to use Subscription 2.0 mode,
  # please manually create the Cloud Firewall instance in the Alibaba Cloud console first, then set this parameter to false
  # to avoid Terraform attempting to create the instance
  create_cloud_firewall_instance = false

  # Member account management (file-based configuration)
  member_account_id_file_path = "${path.module}/member_accounts.yaml"

  # Address books configuration
  address_books = [
    {
      group_name   = "test-ip-address-book"
      group_type   = "ip"
      description  = "Test IP address book"
      address_list = ["192.168.1.0/24", "10.0.0.0/8"]
    }
  ]


  # Internet control policies (file-based configuration)
  # Inbound policies file (must contain an array) - JSON format
  internet_control_policy_in_file_path = "${path.module}/internet_control_policies/in.json"

  # Outbound policies file (must contain an array) - YAML format
  internet_control_policy_out_file_path = "${path.module}/internet_control_policies/out.yaml"

  # Advanced policy settings
  internet_switch = "on"

  # VPC CEN TR Firewall configuration
  vpc_cen_tr_firewalls = [
    {
      transit_router_id         = "tr-uf6e6h5vv5eigxxxxxx"
      cen_id                    = "cen-jhwbspfj5lnxxxxxxxx"
      firewall_name             = "test-vpc-firewall"
      region_no                 = "cn-shanghai"
      route_mode                = "managed"
      firewall_vpc_cidr         = "10.100.0.0/16"
      firewall_subnet_cidr      = "10.100.1.0/24"
      tr_attachment_master_cidr = "10.100.2.0/24"
      tr_attachment_slave_cidr  = "10.100.3.0/24"
      firewall_description      = "Test VPC Firewall"
      tr_attachment_master_zone = "cn-shanghai-m"
    }
  ]

  # VPC Firewall Control Policies (file-based configuration)
  vpc_firewall_control_policies = [
    {
      cen_id                   = "cen-jhwbspfj5lnxxxxxxxx"
      control_policy_file_path = "${path.module}/vpc_control_policies/policies.yaml"
    }
  ]

  # NAT Gateway Firewall configuration
  nat_firewalls = [
    {
      nat_gateway_id = "ngw-uf6hg6eaaqz70xxxxxx"
      proxy_name     = "test-nat-firewall"
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
      vswitch_cidr    = "10.2.10.0/28"
    }
  ]

  # NAT Gateway Firewall Control Policies (file-based configuration)
  nat_firewall_control_policies = [
    {
      nat_gateway_id           = "ngw-uf6hg6eaaqz70xxxxxx"
      control_policy_file_path = "${path.module}/nat_control_policies/policies.yaml"
    }
  ]
}

output "cloud_firewall_instance_id" {
  value = module.cloud_firewall.cloud_firewall_instance_id
}

output "cloud_firewall_instance_status" {
  value = module.cloud_firewall.cloud_firewall_instance_status
}

output "member_account_ids" {
  value = module.cloud_firewall.member_account_ids
}

output "internet_control_policy_count" {
  value = module.cloud_firewall.internet_control_policy_count
}

output "internet_control_policies" {
  value = module.cloud_firewall.internet_control_policies
}

output "address_books" {
  value = module.cloud_firewall.address_books
}

output "vpc_cen_tr_firewalls" {
  value = module.cloud_firewall.vpc_cen_tr_firewalls
}

output "vpc_firewall_control_policies" {
  value = module.cloud_firewall.vpc_firewall_control_policies
}

output "nat_firewalls" {
  value = module.cloud_firewall.nat_firewalls
}

output "nat_firewall_control_policies" {
  value = module.cloud_firewall.nat_firewall_control_policies
}
