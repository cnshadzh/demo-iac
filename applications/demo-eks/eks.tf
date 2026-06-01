#############################
# EKS Cluster and Node Group
#############################
resource "aws_security_group" "node_group" {
  for_each = local.node_groups
  name                   = each.key
  description            = each.key
  vpc_id                 = local.yaml_vars.workload_account.vpc.vpc_id
  ingress {
    description      = "TLS from LB SG"
    from_port        = 30000
    to_port          = 40000
    protocol         = "tcp"
    security_groups  = [
      module.internal-lb-whitelist-sg.security_group_id,
      module.internet-lb-whitelist-sg.security_group_id,
      module.trusted-whitelist-sg.security_group_id,
    ]
  }

  depends_on = [
    module.internal-lb-whitelist-sg,
    module.internet-lb-whitelist-sg,
    module.trusted-whitelist-sg,
   ]
}

  # know issue: sts can't apply provider kubernetes, so we create aws-auth configmap manually
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  // token                  = module.eks.token

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

module "eks" {
  source = "../../modules/terraform-aws-eks/v19.20.0/"

  cluster_name                         = local.eks_vars.eks.cluster_name
  cluster_version                      = local.eks_vars.eks.cluster_version
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = local.eks_vars.eks.cluster_endpoint_public_access_cidrs

  cluster_addons = {
    coredns = {
      preserve    = true
      most_recent = false
      addon_version = local.eks_vars.eks.addon.coredns_version

      timeouts = {
        create = "10m"
        delete = "10m"
      }
    }
    aws-ebs-csi-driver = {
      most_recent = false
      addon_version = local.eks_vars.eks.addon.aws_ebs_csi_driver_version
      timeouts = {
        create = "10m"
        delete = "10m"
      }
    }
    aws-efs-csi-driver = {
      most_recent = false
      addon_version = local.eks_vars.eks.addon.aws_efs_csi_driver_version
      timeouts = {
        create = "10m"
        delete = "10m"
      }
    }
    kube-proxy = {
      most_recent = false
      addon_version = local.eks_vars.eks.addon.kube_proxy_version
      timeouts = {
        create = "10m"
        delete = "10m"
      }
    }
    vpc-cni = {
      most_recent = false
      addon_version = local.eks_vars.eks.addon.vpc_cni_version
      timeouts = {
        create = "10m"
        delete = "10m"
      }
    }
  }

  # External encryption key
  create_kms_key = false

  cluster_encryption_config = []

  iam_role_additional_policies = {
    additional = aws_iam_policy.additional.arn
  }

  vpc_id                   = local.yaml_vars.workload_account.vpc.vpc_id
  subnet_ids               = data.aws_subnets.private_subnet.ids
  control_plane_subnet_ids = data.aws_subnets.private_subnet.ids

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
    # Test: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/2319
    ingress_source_security_group_id = {
      description              = "Ingress from another computed security group"
      protocol                 = "tcp"
      from_port                = 22
      to_port                  = 22
      type                     = "ingress"
      source_security_group_id = module.trusted-whitelist-sg.security_group_id
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    # Test: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/2319
    ingress_source_security_group_id = {
      description              = "Ingress from another computed security group"
      protocol                 = "tcp"
      from_port                = 22
      to_port                  = 22
      type                     = "ingress"
      source_security_group_id = module.trusted-whitelist-sg.security_group_id
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type                              = "AL2_x86_64"
    instance_types                        = ["m5.large", "m5.xlarge", "m5.2xlarge", "m5.4xlarge"]
    key_name                              = local.eks_vars.eks.key_name
    create_iam_role                       = false
    iam_role_arn                          = aws_iam_role.node_group.arn
    iam_role_attach_cni_policy            = false
    create_launch_template                = true
    create_node_security_group            = true
    use_name_prefix                       = true
    launch_template_use_name_prefix       = true
    attach_cluster_primary_security_group = true
    vpc_security_group_ids                = [module.trusted-whitelist-sg.security_group_id]
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = 100
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 150
          delete_on_termination = true
        }
      }
    }
  }

  # eks_managed_node_groups = local.node_groups
  eks_managed_node_groups = {for k, v in local.node_groups:
    k => merge(v, {vpc_security_group_ids:[aws_security_group.node_group[k].id]})}



  # Create a new cluster where both an identity provider and Fargate profile is created
  # will result in conflicts since only one can take place at a time
  # # OIDC Identity provider
  # cluster_identity_providers = {
  #   sts = {
  #     client_id = "sts.amazonaws.com"
  #   }
  # }

  # aws-auth configmap
  # know issue: sts can't apply provider kubernetes, so we create aws-auth configmap manually
  create_aws_auth_configmap = false
  manage_aws_auth_configmap = false

  aws_auth_node_iam_role_arns_non_windows = []

  aws_auth_roles = []
  // aws_auth_roles = local.eks_vars.eks.map_roles

  aws_auth_users = []

  aws_auth_accounts = []

  tags = local.tags

  depends_on = [
    aws_iam_role.node_group,
    aws_security_group.node_group,
    module.trusted-whitelist-sg,
    aws_iam_role_policy_attachment.ecr_ro_role_policy,
    aws_iam_role_policy_attachment.ssm_managed_instance_core_role_policy,
    aws_iam_role_policy_attachment.eks_worker_node_role_policy,
    aws_iam_role_policy_attachment.eks_cni_role_policy,
  ]
}

resource "aws_iam_policy" "additional" {

  name = "${local.eks_vars.eks.cluster_name}-${var.region}-eks-additional"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

##########################################
# VPC endpoints for s3 to private subnets
##########################################

resource "aws_vpc_endpoint" "s3" {

  vpc_id = local.yaml_vars.workload_account.vpc.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  tags = local.tags
}

resource "aws_vpc_endpoint_route_table_association" "s3" {

  count           = length(data.aws_route_tables.private_route_table.ids)
  route_table_id  = tolist(data.aws_route_tables.private_route_table.ids)[count.index]
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_vpc_endpoint" "athena" {

  vpc_id = local.yaml_vars.workload_account.vpc.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.athena"
  vpc_endpoint_type = "Interface"
  subnet_ids = data.aws_subnets.private_subnet.ids
  private_dns_enabled = true
  tags = local.tags
}

########################################
# Logging S3 bucket
########################################

module "logging_s3" {
  source                                     = "../../modules/app-logging-s3/v0.1/"
  for_each                                   = local.eks_vars.products
  s3_name                                    = join("-",[each.key, local.eks_vars.eks.cluster_name, data.aws_region.current.name, "logging"])

  cluster_name                               = local.eks_vars.eks.cluster_name
  versioning_enabled                         = each.value.logging_s3.versioning_enabled
  force_destroy                              = each.value.logging_s3.force_destroy
  lifecycle_rule_enabled                     = each.value.logging_s3.lifecycle_rule_enabled
  lifecycle_rule_prefix                      = each.value.logging_s3.lifecycle_rule_prefix
  standard_ia_transition_days                = each.value.logging_s3.standard_ia_transition_days
  glacier_transition_days                    = each.value.logging_s3.glacier_transition_days
  expiration_days                            = each.value.logging_s3.expiration_days
  glacier_noncurrent_version_transition_days = each.value.logging_s3.glacier_noncurrent_version_transition_days
  noncurrent_version_expiration_days         = each.value.logging_s3.noncurrent_version_expiration_days

  tags                                       = merge(local.tags, each.value.tags)
}

########################################
# EFS
########################################

########################################
# product S3 bucket
########################################
# product bucket for storing products data, file which are for microservices uploading and downloading
resource "aws_s3_bucket" "product" {
  for_each                                   = local.eks_vars.products
  bucket                                     = join("-",[each.key, local.eks_vars.eks.cluster_name, data.aws_region.current.name, "product"])
  force_destroy                              = false

  tags                                       = merge(local.tags, each.value.tags)
  depends_on                                 = [ module.logging_s3 ]
}

resource "aws_s3_bucket_logging" "product" {
  for_each                                   = local.eks_vars.products
  bucket                                     = join("-",[each.key, local.eks_vars.eks.cluster_name, data.aws_region.current.name, "product"])

  target_bucket                              = join("-",[each.key, local.eks_vars.eks.cluster_name, data.aws_region.current.name, "logging"])
  target_prefix                              = "product/"
  depends_on                                 = [ aws_s3_bucket.product ]
}

########################################
# IAM roles and service account
########################################

resource "aws_iam_policy" "product_s3_ro" {
  // each product would have its own S3 bucket for storing files, data
  // this policy is for product's s3 bucket readonly

  for_each    = local.eks_vars.products
  name        = join("-",[each.key, local.eks_vars.eks.cluster_name, data.aws_region.current.name, "ro-policy"])
  path        = "/"
  description = "product s3 readonly policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject*",
          "s3:ListObject*",
        ]
        Effect   = "Allow"
        Resource = "arn:${data.aws_partition.current.partition}:s3:::${join("-",[each.key, local.eks_vars.eks.cluster_name, data.aws_region.current.name, "product"])}/"
      },
    ]
  })
}

resource "aws_iam_policy" "product_s3_rw" {
  // each product would have its own S3 bucket for storing files, data
  // this policy is for product's s3 bucket write/read

  for_each    = local.eks_vars.products
  name        = join("-",[each.key, local.eks_vars.eks.cluster_name, data.aws_region.current.name, "rw-policy"])
  path        = "/"
  description = "product s3 read write policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject*",
          "s3:PutObject*",
        ]
        Effect   = "Allow"
        Resource = [
          "arn:${data.aws_partition.current.partition}:s3:::${join("-",[each.key, local.eks_vars.eks.cluster_name, data.aws_region.current.name, "product"])}/",
          "arn:${data.aws_partition.current.partition}:s3:::${join("-",[each.key, local.eks_vars.eks.cluster_name, data.aws_region.current.name, "product"])}/*",
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "grafana-policy" {

  name        = "${local.eks_vars.eks.cluster_name}-${var.region}-GrafanaAccessPolicy"
  path        = "/"
  description = "GrafanaAccessPolicy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = templatefile("${path.module}/templates/grafana-policy.json", {
    partition = data.aws_partition.current.partition
  })
}

resource "aws_iam_role" "grafana-sa" {

  count      = strcontains(local.eks_vars.eks.cluster_name, "eks") ? 1 : 0
  tags = local.tags
  name = join("-",[local.eks_vars.eks.cluster_name, var.region, "grafana-sa-role"])
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${module.eks.oidc_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${local.oidc}:aud": "sts.amazonaws.com",
            "${local.oidc}:sub": "system:serviceaccount:monitoring:grafana"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "grafana" {

  count      = strcontains(local.eks_vars.eks.cluster_name, "eks") ? 1 : 0
  role       = aws_iam_role.grafana-sa[0].name
  policy_arn = aws_iam_policy.grafana-policy.arn
}

resource "aws_iam_policy" "cluster-autoscaler-policy" {

  name        = "${local.eks_vars.eks.cluster_name}-${var.region}-AmazonEKSClusterAutoscalerPolicy"
  path        = "/"
  description = "AmazonEKSClusterAutoscalerPolicy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = file("${path.module}/templates/cluster-autoscaler-policy.json")
}

resource "aws_iam_policy" "aws-lb-controller-sa-policy" {

  name        = "${local.eks_vars.eks.cluster_name}-${var.region}-AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "AWSLoadBalancerControllerIAMPolicy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = templatefile("${path.module}/templates/aws-load-balancer-controller-iam-policy.json", {
    partition = data.aws_partition.current.partition
  })
}

resource "aws_iam_policy" "ebs-csi-controller-sa-policy" {

  name        = "${local.eks_vars.eks.cluster_name}-${var.region}-AWSEBSCSIControllerIAMPolicy"
  path        = "/"
  description = "AWSEBSCSIControllerIAMPolicy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = templatefile("${path.module}/templates/ebs-csi-controller-sa-policy.json", {
    partition = data.aws_partition.current.partition
  })
}

resource "aws_iam_policy" "efs-csi-controller-sa-policy" {

  name        = "${local.eks_vars.eks.cluster_name}-${var.region}-AWSEFSCSIControllerIAMPolicy"
  path        = "/"
  description = "AWSEFSCSIControllerIAMPolicy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = templatefile("${path.module}/templates/efs-csi-controller-sa-policy.json", {
    partition = data.aws_partition.current.partition
  })
}

locals {
  oidc = replace(module.eks.cluster_oidc_issuer_url,"https://", "")
}

resource "aws_iam_role" "cluster-autoscaler" {

  tags = local.tags
  name = join("-",[local.eks_vars.eks.cluster_name, var.region, "cluster-autoscaler-role"])
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${module.eks.oidc_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${local.oidc}:aud": "sts.amazonaws.com",
            "${local.oidc}:sub": "system:serviceaccount:kube-system:aws-cluster-autoscaler"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "aws-lb-controller-sa" {

  tags = local.tags
  name = join("-",[local.eks_vars.eks.cluster_name, var.region, "aws-lb-controller-sa-role"])
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${module.eks.oidc_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${local.oidc}:aud": "sts.amazonaws.com",
            "${local.oidc}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "ebs-csi-controller" {

  tags = local.tags
  name = join("-",[local.eks_vars.eks.cluster_name, var.region, "ebs-csi-controller-role"])
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${module.eks.oidc_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${local.oidc}:aud": "sts.amazonaws.com",
            "${local.oidc}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "efs-csi-controller" {

  tags = local.tags
  name = join("-",[local.eks_vars.eks.cluster_name, var.region, "efs-csi-controller-role"])
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${module.eks.oidc_provider_arn}"
        }
        Condition = {
          StringLike = {
            "${local.oidc}:aud": "sts.amazonaws.com",
            "${local.oidc}:sub": "system:serviceaccount:kube-system:efs-csi-*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster-autoscaler-attach" {

  role       = aws_iam_role.cluster-autoscaler.name
  policy_arn = aws_iam_policy.cluster-autoscaler-policy.arn
}

resource "aws_iam_role_policy_attachment" "aws-lb-controller-attach" {

  role       = aws_iam_role.aws-lb-controller-sa.name
  policy_arn = aws_iam_policy.aws-lb-controller-sa-policy.arn
}

resource "aws_iam_role_policy_attachment" "ebs-csi-controller-attach" {

  role       = aws_iam_role.ebs-csi-controller.name
  policy_arn = aws_iam_policy.ebs-csi-controller-sa-policy.arn
}

resource "aws_iam_role_policy_attachment" "efs-csi-controller-attach" {

  role       = aws_iam_role.efs-csi-controller.name
  policy_arn = aws_iam_policy.efs-csi-controller-sa-policy.arn
}

resource "aws_iam_role" "logging-operator-sa" {

  tags = local.tags
  name = join("-",[local.eks_vars.eks.cluster_name, var.region, "logging-operator-sa-role"])
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${module.eks.oidc_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${local.oidc}:aud": "sts.amazonaws.com",
            "${local.oidc}:sub": "system:serviceaccount:logging:logging-operator"
          }
        }
      }
    ]
  })
}


resource aws_iam_policy "s3" {

  name = "${local.eks_vars.eks.cluster_name}-${var.region}-s3-logging-policy"
  path        = "/"
  description = "app s3 logging policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
           "es:ESHttp*",
           "s3:ListBucket",
           "s3:GetObject",
           "s3:GetBucketLocation",
           "s3:GetObjectVersion",
           "s3:GetObjectACL",
           "s3:PutObject*",
           "s3:CreateBucket"
        ]
        Effect   = "Allow"
        Resource = "arn:${data.aws_partition.current.partition}:s3:::${join("-",["*", local.eks_vars.eks.cluster_name, data.aws_region.current.name, "logging"])}/"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "logging" {

  role       = aws_iam_role.logging-operator-sa.name
  policy_arn = aws_iam_policy.s3.arn
}

resource "aws_iam_role" "node_group" {

  name = "${local.eks_vars.eks.cluster_name}-${var.region}-node-group-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core_role_policy" {

  role       = aws_iam_role.node_group.name
  policy_arn = data.aws_iam_policy.ssm_managed_instance_core_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_role_policy" {

  role       = aws_iam_role.node_group.name
  policy_arn = data.aws_iam_policy.eks_worker_node_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecr_ro_role_policy" {

  role       = aws_iam_role.node_group.name
  policy_arn = data.aws_iam_policy.ecr_ro_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "eks_cni_role_policy" {

  role       = aws_iam_role.node_group.name
  policy_arn = data.aws_iam_policy.eks_cni_role_policy.arn
}
