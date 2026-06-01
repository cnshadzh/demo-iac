#
# Security Group Resources
#
resource "aws_security_group" "default" {
  count       = var.use_existing_security_groups == false ? 1 : 0
  description = var.security_group_description
  vpc_id      = var.vpc_id
  name_prefix = "${var.replication_group_id}_redis_sg"
  tags        = var.tags
}

resource "aws_security_group_rule" "egress" {
  count             = var.use_existing_security_groups == false && length(var.egress_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow outbound traffic from existing cidr blocks"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.egress_cidr_blocks
  security_group_id = join("", aws_security_group.default.*.id)
  type              = "egress"
}

resource "aws_security_group_rule" "ingress_security_groups" {
  count                    = var.use_existing_security_groups == false ? length(var.allowed_security_groups) : 0
  description              = "Allow inbound traffic from existing Security Groups"
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  source_security_group_id = var.allowed_security_groups[count.index]
  security_group_id        = join("", aws_security_group.default.*.id)
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count             = var.use_existing_security_groups == false && length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = join("", aws_security_group.default.*.id)
  type              = "ingress"
}

locals {
  elasticache_subnet_group_name = var.elasticache_subnet_group_name != "" ? var.elasticache_subnet_group_name : join("", aws_elasticache_subnet_group.default.*.name)
}

resource "aws_elasticache_subnet_group" "default" {
  count       = length(var.subnets) > 0 ? 1 : 0
  name        = "${var.replication_group_id}-redis-subnet"
  subnet_ids  = var.subnets
}

resource "aws_elasticache_parameter_group" "default" {
  name   = "${var.replication_group_id}-parameter-group"
  family = var.family

  dynamic "parameter" {
    for_each = var.cluster_mode_enabled ? concat([{ name = "cluster-enabled", value = "yes" }], var.parameter) : var.parameter
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
}

resource "aws_elasticache_replication_group" "default" {
  auth_token                    = var.transit_encryption_enabled ? var.auth_token : null
  replication_group_id          = var.replication_group_id
  description                   = var.replication_group_id
  node_type                     = var.instance_type
  num_cache_clusters            = var.cluster_mode_enabled ? null : var.cluster_size
  port                          = var.port
  parameter_group_name          = join("", aws_elasticache_parameter_group.default.*.name)
#  Clovis: cant run pass with this param
#  availability_zones            = length(var.availability_zones) == 0 ? null : [for n in range(0, var.cluster_size) : element(var.availability_zones, n)]
  automatic_failover_enabled    = var.automatic_failover_enabled
  multi_az_enabled              = var.multi_az_enabled
  subnet_group_name             = local.elasticache_subnet_group_name
  security_group_ids            = var.use_existing_security_groups ? var.existing_security_groups : [join("", aws_security_group.default.*.id)]
  maintenance_window            = var.maintenance_window
  notification_topic_arn        = var.notification_topic_arn
  engine_version                = var.engine_version
  at_rest_encryption_enabled    = var.at_rest_encryption_enabled
  transit_encryption_enabled    = var.auth_token != null ? coalesce(true, var.transit_encryption_enabled) : var.transit_encryption_enabled
  kms_key_id                    = var.at_rest_encryption_enabled ? var.kms_key_id : null
  snapshot_name                 = var.snapshot_name
  snapshot_arns                 = var.snapshot_arns
  snapshot_window               = var.snapshot_window
  snapshot_retention_limit      = var.snapshot_retention_limit
  final_snapshot_identifier     = var.final_snapshot_identifier
  apply_immediately             = var.apply_immediately

  replicas_per_node_group       = var.cluster_mode_enabled ? var.cluster_mode_replicas_per_node_group : var.replicas_per_node_group
  num_node_groups               = var.cluster_mode_enabled ? var.cluster_mode_num_node_groups : 0
  tags                          = var.tags

}