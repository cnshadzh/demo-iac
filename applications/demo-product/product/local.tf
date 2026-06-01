locals {
  secretsmanager_names = { for k, v in merge(var.aurora, var.rds) : k => v.secretsmanager_name if try(v.create_random_password, true) == false }
  db_passwords = { for k, v in data.aws_secretsmanager_secret_version.db_admin : k => jsondecode(v.secret_string)["password"]}
  // abbreviations of regions
  abv_of_regions = {
    "eu-west-1" = "irl"
    "eu-central-1" = "fra"
    "ap-southeast-1" = "sin"
    "ap-northeast-1" = "tyo"
  }

}