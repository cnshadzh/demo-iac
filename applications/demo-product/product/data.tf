data "aws_secretsmanager_secret" "db_admin" {
  for_each = local.secretsmanager_names
  name     = each.value
}

data "aws_secretsmanager_secret_version" "db_admin" {
  for_each  = local.secretsmanager_names
  secret_id = data.aws_secretsmanager_secret.db_admin[each.key].id
}
