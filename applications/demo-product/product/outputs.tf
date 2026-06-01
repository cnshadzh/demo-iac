# redis
output "redis_id" {
  value       = tomap({
    for k, v in module.redis: k => v.id
  })
  description = "Redis cluster ID"
}

output "redis_endpoint" {
  value       = tomap({
    for k, v in module.redis: k => v.endpoint
  })
  description = "Redis primary endpoint"
}

output "redis_member_clusters" {
  value       = tomap({
    for k, v in module.redis: k => v.member_clusters
  })
  description = "Redis cluster members"
}

output "redis_security_group_id" {
  value       = tomap({
    for k, v in module.redis: k => v.security_group_id
  })
  description = "Redis security groups"
}

# rds
output "db_instance_address" {
  value       = tomap({
    for k, v in module.rds: k => v.db_instance_address
  })
  description = "The address of the RDS instance"
}

output "db_instance_endpoint" {
  value       = tomap({
    for k, v in module.rds: k => v.db_instance_endpoint
  })
  description = "The connection endpoint"
}

output "db_instance_domain" {
  value       = tomap({
    for k, v in module.rds: k => v.db_instance_domain
  })
  description = "The ID of the Directory Service Active Directory domain the instance is joined to"
}
