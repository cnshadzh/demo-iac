module "trusted-whitelist-sg" {
  source                  = "../../modules/common-security-group/v0.1/modules/trusted"
  name                    = "${local.eks_vars.sgs.trusted_whitelist_sg.sg_name}-${local.account_variables.environment}"
  description             = local.eks_vars.sgs.trusted_whitelist_sg.description
  vpc_id                  = local.yaml_vars.workload_account.vpc.vpc_id
  ingress_cidr_blocks     = local.eks_vars.sgs.trusted_whitelist_sg.ingress_cidr_blocks

  tags                    = local.tags
}

module "internal-lb-whitelist-http-sg" {
  source                  = "../../modules/common-security-group/v0.1/modules/http-80"
  name                    = "${local.eks_vars.sgs.internal_lb_whitelist_sg.sg_name}-${local.account_variables.environment}"
  description             = local.eks_vars.sgs.internal_lb_whitelist_sg.description
  vpc_id                  = local.yaml_vars.workload_account.vpc.vpc_id
  ingress_cidr_blocks     = local.eks_vars.sgs.internal_lb_whitelist_sg.ingress_cidr_blocks
  tags                    = local.tags
}

module "internet-lb-whitelist-http-sg" {
  source                  = "../../modules/common-security-group/v0.1/modules/http-80"
  name                    = "${local.eks_vars.sgs.internet_lb_whitelist_sg.sg_name}-${local.account_variables.environment}"
  description             = local.eks_vars.sgs.internet_lb_whitelist_sg.description
  vpc_id                  = local.yaml_vars.workload_account.vpc.vpc_id
  ingress_cidr_blocks     = local.eks_vars.sgs.internet_lb_whitelist_sg.ingress_cidr_blocks

  tags                    = local.tags
}

module "internal-lb-whitelist-sg" {
  source                  = "../../modules/common-security-group/v0.1/modules/https-443"
  name                    = "${local.eks_vars.sgs.internal_lb_whitelist_sg.sg_name}-${local.account_variables.environment}"
  description             = local.eks_vars.sgs.internal_lb_whitelist_sg.description
  vpc_id                  = local.yaml_vars.workload_account.vpc.vpc_id
  ingress_cidr_blocks     = local.eks_vars.sgs.internal_lb_whitelist_sg.ingress_cidr_blocks

  tags                    = local.tags
}

module "internet-lb-whitelist-sg" {
  source                  = "../../modules/common-security-group/v0.1/modules/https-443"
  name                    = "${local.eks_vars.sgs.internet_lb_whitelist_sg.sg_name}-${local.account_variables.environment}"
  description             = local.eks_vars.sgs.internet_lb_whitelist_sg.description
  vpc_id                  = local.yaml_vars.workload_account.vpc.vpc_id
  ingress_cidr_blocks     = local.eks_vars.sgs.internet_lb_whitelist_sg.ingress_cidr_blocks

  tags                    = local.tags
}
