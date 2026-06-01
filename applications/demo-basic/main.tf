module "vpc" {
  source = "../../modules/vpc/v0.1/"

  name = local.account_variables.vpc.name
  cidr = local.account_variables.vpc.cidr
  azs             = local.account_variables.vpc.azs
  private_subnets = local.account_variables.vpc.private_subnets
  public_subnets  = local.account_variables.vpc.public_subnets
  protected_subnets  = local.account_variables.vpc.protected_subnets
  enable_nat_gateway = local.account_variables.vpc.enable_nat_gateway
  single_nat_gateway =local.account_variables.vpc.single_nat_gateway
  enable_dns_hostnames = local.account_variables.vpc.enable_dns_hostnames
  enable_dns_support = local.account_variables.vpc.enable_dns_support
  ## whether enable flow logs and configure the vpc flow logs destination
  enable_flow_logs = local.account_variables.vpc.enable_flow_logs
  # vpc_flow_logs_destination = data.aws_s3_bucket.logging_flowlogs_bucket.arn
  ## whether enable ssm enpoints and private dns for this enpoint
  enable_ssm_endpoint = local.account_variables.vpc.enable_ssm_endpoint
  ssm_endpoint_private_dns_enabled = local.account_variables.vpc.ssm_endpoint_private_dns_enabled
  enable_ssmmessages_endpoint = local.account_variables.vpc.enable_ssmmessages_endpoint
  ssmmessages_endpoint_private_dns_enabled = local.account_variables.vpc.ssmmessages_endpoint_private_dns_enabled
  enable_ec2messages_endpoint = local.account_variables.vpc.enable_ec2messages_endpoint
  ec2messages_endpoint_private_dns_enabled = local.account_variables.vpc.ec2messages_endpoint_private_dns_enabled
  ## whether enable network acl for public subnet with default rules.
  public_dedicated_network_acl = local.account_variables.vpc.public_dedicated_network_acl
  ## Attached the security group id for endpoints.
  endpoints_security_group_ids = [module.endpoints_security_group.this_security_group_id]
  # tags = local.account_variables.vpc.tags
  private_subnet_tags= contains(keys(local.account_variables.vpc),"private_subnet_tags") ? local.account_variables.vpc.private_subnet_tags : null
  environment = var.environment
}

##########################################################
## security group for vpc endpoints
##########################################################
module "endpoints_security_group" {
    source = "../../modules/securitygroup/v0.1/"
  #   providers = {
  #   aws = aws.this
  #  }
   create_security_group =local.account_variables.vpc.create_security_group
   name = "vpc_endpoints_security_group"
   ingress_cidr_blocks = [local.account_variables.vpc.cidr]
   egress_cidr_blocks = ["0.0.0.0/0"]
   vpc_id = module.vpc.vpc_id
   ingress_rules = ["https-443"]
   egress_rules = ["all"]
}


