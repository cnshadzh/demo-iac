### Load the config files as the local variables.
locals {
  yaml_vars         = yamldecode(file("${abspath(path.module)}/../../config/${var.region}/demo-${var.environment}/${var.config_name}"))
  account_id        = local.yaml_vars["workload_account"]["account_id"]
  account_variables = local.yaml_vars["workload_account"]
}
