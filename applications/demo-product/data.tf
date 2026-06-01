data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_availability_zones" "available" {}

data "aws_subnets" "protected_subnet" {

  filter {
    name   = "vpc-id"
    values = [local.yaml_vars.workload_account.vpc.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["*${var.environment}-protected-subnet*"]
  }
}

data "aws_subnets" "private_subnet" {
  
  filter {
    name   = "vpc-id"
    values = [local.yaml_vars.workload_account.vpc.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["*${var.environment}-private-subnet*"]
  }
}

data "aws_subnet" "private_subnet_a" {
  
  filter {
    name   = "vpc-id"
    values = [local.yaml_vars.workload_account.vpc.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["*${var.environment}-private-subnet-1a"]
  }
}

data "aws_subnet" "private_subnet_b" {
  
  filter {
    name   = "vpc-id"
    values = [local.yaml_vars.workload_account.vpc.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["*${var.environment}-private-subnet-1b"]
  }
}

data "aws_subnet" "private_subnet_c" {
  
  filter {
    name   = "vpc-id"
    values = [local.yaml_vars.workload_account.vpc.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["*${var.environment}-private-subnet-1c"]
  }
}

data "aws_route_tables" "private_route_table" {
  
  vpc_id = local.yaml_vars.workload_account.vpc.vpc_id

  filter {
    name   = "tag:Name"
    values = ["*${var.environment}-private-route-table*"]
  }
}
