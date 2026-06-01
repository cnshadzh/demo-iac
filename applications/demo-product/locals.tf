### Load the config files as the local variables.
locals {
  product_vars = yamldecode(file("${abspath(path.module)}/../../config/${var.region}/demo-${var.environment}/${var.product}.yaml"))
  yaml_vars = yamldecode(file("${abspath(path.module)}/../../config/${var.region}/demo-${var.environment}/${var.config_name}"))
  eks_vars = yamldecode(file("${abspath(path.module)}/../../config/${var.region}/demo-${var.environment}/${var.eks_config_name}"))

  account_id        = local.yaml_vars["workload_account"]["account_id"]
  account_variables = local.yaml_vars["workload_account"]

  tags = merge(tomap(local.account_variables.tags), local.product_vars.tags)
}