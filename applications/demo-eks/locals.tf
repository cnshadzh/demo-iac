### Load the config files as the local variables.
locals {
  yaml_vars = yamldecode(file("${abspath(path.module)}/../../config/${var.region}/demo-${var.environment}/${var.config_name}"))
  eks_vars = yamldecode(file("${abspath(path.module)}/../../config/${var.region}/demo-${var.environment}/${var.eks_config_name}"))

  account_id        = local.yaml_vars.workload_account.account_id
  account_variables = local.yaml_vars.workload_account
  tags = tomap(local.account_variables.tags)

  node_groups = merge([
    for product_name, product_config in local.eks_vars.products : {
      for node_group_name, node_group_config in product_config.node_groups :
      "${product_name}-${node_group_name}" => merge(
        node_group_config,
        {
          tags = product_config.tags
        }
      )
    }
  ]...)



  azs = slice(data.aws_availability_zones.available.names, 0, 3)
  mount_targets  = { for k, v in zipmap([data.aws_subnet.private_subnet_a.availability_zone ,data.aws_subnet.private_subnet_b.availability_zone  ,data.aws_subnet.private_subnet_c.availability_zone  ],
    [data.aws_subnet.private_subnet_a.id,data.aws_subnet.private_subnet_b.id ,data.aws_subnet.private_subnet_c.id ]) : k => { subnet_id = v } }
  private_subnets_cidr_blocks = [data.aws_subnet.private_subnet_a.cidr_block ,data.aws_subnet.private_subnet_b.cidr_block ,data.aws_subnet.private_subnet_c.cidr_block]
}
