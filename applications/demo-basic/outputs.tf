
output "vpc_id" {
    value = module.vpc.vpc_id
}

output "protected_subnet_ids" {
    value = module.vpc.protected_subnets
}

output "private_subnet_ids" {
    value = module.vpc.private_subnets
}

output "public_subnet_ids" {
    value = module.vpc.public_subnets
}

output "endpoints_security_group_id" {
    value = module.endpoints_security_group.this_security_group_id
}



