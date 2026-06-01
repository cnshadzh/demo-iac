module "redis" {
  source                            = "../../../modules/redis/v0.1"

  for_each                             = var.redis
  vpc_id                               = var.vpc_id
  existing_security_groups             = [var.redis_sg]
  allowed_cidr_blocks                  = each.value.allowed_cidr_blocks
  allowed_security_groups              = each.value.allowed_security_groups
  subnets                              = var.private_subnets
  cluster_size                         = each.value.cluster_size
  instance_type                        = each.value.instance_type
  apply_immediately                    = true
  automatic_failover_enabled           = each.value.automatic_failover_enabled
  engine_version                       = each.value.engine_version
  family                               = each.value.family
  at_rest_encryption_enabled           = each.value.at_rest_encryption_enabled ? each.value.at_rest_encryption_enabled : false
  transit_encryption_enabled           = each.value.transit_encryption_enabled ? each.value.transit_encryption_enabled : false
  replication_group_id                 = each.key
  cluster_mode_enabled                 = each.value.cluster_mode_enabled
  cluster_mode_replicas_per_node_group = each.value.cluster_mode_replicas_per_node_group
  cluster_mode_num_node_groups         = each.value.cluster_mode_num_node_groups

  tags                                 = try(merge(var.tags, each.value.tags), var.tags)
}
