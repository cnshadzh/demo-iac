# redis
output "redis_id" {
  value       = module.product.redis_id
  description = "Redis cluster ID"
}

output "redis_endpoint" {
  value       = module.product.redis_endpoint
  description = "Redis primary endpoint"
}

output "redis_member_clusters" {
  value       = module.product.redis_member_clusters
  description = "Redis cluster members"
}

output "redis_security_group_id" {
  value       = module.product.redis_security_group_id
  description = "Redis security groups"
}

# rds
output "db_instance_address" {
  value       = module.product.db_instance_address
  description = "The address of the RDS instance"
}

output "db_instance_endpoint" {
  value       = module.product.db_instance_endpoint
  description = "The connection endpoint"
}

output "db_instance_domain" {
  value       = module.product.db_instance_domain
  description = "The ID of the Directory Service Active Directory domain the instance is joined to"
}
