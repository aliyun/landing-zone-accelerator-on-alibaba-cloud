output "policies" {
  description = "List of control policies with their attachments."
  value = [
    for policy_name, policy in alicloud_resource_manager_control_policy.default : {
      name = policy_name
      id   = policy.id
      attachments = [
        for key, attachment in alicloud_resource_manager_control_policy_attachment.default : {
          target_id     = attachment.target_id
          attachment_id = attachment.id
        } if startswith(key, "${policy_name}-")
      ]
    }
  ]
}
