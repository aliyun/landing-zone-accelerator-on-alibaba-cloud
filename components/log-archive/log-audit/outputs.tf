# Project outputs
output "project_name" {
  description = "Name of the SLS project"
  value       = local.project_name
}

# Logstore outputs
output "logstore_names" {
  description = "Names of created logstores"
  value = {
    for policy_name, logstore in alicloud_log_store.this : policy_name => logstore.name
  }
}

# Collection policy outputs
output "collection_policy_names" {
  description = "Names of created collection policies"
  value = {
    for policy_name, policy in alicloud_sls_collection_policy.this : policy_name => policy.policy_name
  }
}

output "collection_policy_ids" {
  description = "IDs of created collection policies"
  value = {
    for policy_name, policy in alicloud_sls_collection_policy.this : policy_name => policy.id
  }
}

output "collection_policy_status" {
  description = "Status of collection policies (enabled/disabled)"
  value = {
    for policy_name, policy in alicloud_sls_collection_policy.this : policy_name => policy.enabled
  }
}

# Summary outputs
output "collection_policies_summary" {
  description = "Summary of collection policies by product_code"
  value = {
    for product_code in distinct([for policy in var.collection_policies : policy.product_code]) :
    product_code => {
      count = length([for policy in var.collection_policies : policy if policy.product_code == product_code])
      policies = [
        for policy in var.collection_policies : {
          name      = policy.policy_name
          data_code = policy.data_code
          enabled   = policy.enabled
        } if policy.product_code == product_code
      ]
    }
  }
}
