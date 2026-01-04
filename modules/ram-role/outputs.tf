output "role_name" {
  description = "Name of the ram role"
  value       = module.ram_role.role_name
}

output "role_arn" {
  description = "ARN of RAM role"
  value       = module.ram_role.role_arn
}

output "role_id" {
  description = "ID of RAM role"
  value       = module.ram_role.role_id
}
