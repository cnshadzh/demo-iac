
module "rds" {
  source                                = "../../../modules/rds/v6.3.0"

  for_each                              = var.rds
  identifier                            = each.key
  engine                                = each.value.engine
  engine_version                        = each.value.engine_version
  family                                = each.value.family
  username                              = each.value.username
  major_engine_version                  = each.value.major_engine_version
  instance_class                        = each.value.instance_class

  allocated_storage                     = each.value.allocated_storage
  max_allocated_storage                 = each.value.max_allocated_storage
  storage_encrypted                     = true
  db_name                               = replace(title(replace("${each.key}","-"," "))," ","")

  port                                  = each.value.port
  multi_az                              = each.value.multi_az
  create_db_subnet_group                = true
  subnet_ids                            = var.protected_subnets
  allowed_security_groups               = each.value.allowed_security_groups
  allowed_cidr_blocks                   = each.value.allowed_cidr_blocks
  vpc_security_group_ids                = [var.rds_sg]
  maintenance_window                    = try(each.value.maintenance_window, "sun:20:00-sun:21:00")
  backup_window                         = "03:00-06:00"
  enabled_cloudwatch_logs_exports       = each.value.enabled_cloudwatch_logs_exports

  backup_retention_period               = each.value.backup_retention_period
  skip_final_snapshot                   = true
  deletion_protection                   = false

  performance_insights_enabled          = each.value.performance_insights_enabled
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "${each.key}-monitoring-role-name"
  monitoring_role_description           = "Description for monitoring role"

  password                              = try(local.db_passwords[each.key], null)

  parameters                            =  each.value.parameters

  tags                                  = try(merge(var.tags, each.value.tags), var.tags)
}
