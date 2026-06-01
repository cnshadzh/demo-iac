resource "aws_security_group" "rds" {
  name        = "${local.product_vars.product_name}-rds-sg"
  description = "${local.product_vars.product_name}-rds-sg"
  vpc_id      = local.account_variables.vpc.vpc_id
  tags        = local.tags
}

resource "aws_security_group" "redis" {
  name        = "${local.product_vars.product_name}-redis-sg"
  description = "${local.product_vars.product_name}-redis-sg"
  vpc_id      = local.account_variables.vpc.vpc_id
  tags        = local.tags
}

module "product" {
  source                 = "./product"
  tags                   = local.tags
  region                 = var.region

  vpc_id                 = local.account_variables.vpc.vpc_id
  account_id             = local.account_id
  partition              = data.aws_partition.current.partition
  product                = local.product_vars.product_name
  environment_name       = var.environment
  eks_name               = local.eks_vars.eks.cluster_name
  protected_subnets      = data.aws_subnets.protected_subnet.ids
  private_subnet_cidrs   = [data.aws_subnet.private_subnet_a.cidr_block ,data.aws_subnet.private_subnet_b.cidr_block ,data.aws_subnet.private_subnet_c.cidr_block]
  private_subnets        = data.aws_subnets.private_subnet.ids

  # rds
  rds                    = local.product_vars.rds
  rds_sg                 = aws_security_group.rds.id

  # redis
  redis                  = local.product_vars.redis
  redis_sg               = aws_security_group.redis.id

}
