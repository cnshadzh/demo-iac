################################################################################
# EFS Module
################################################################################

module "efs" {
  source = "../../modules/terraform-aws-efs/v1.3.1/"

  # File system
  name           = "${local.eks_vars.eks.cluster_name}-efs"
  creation_token = "${local.eks_vars.eks.cluster_name}-efs"
  encrypted      = true

  performance_mode                = local.yaml_vars.workload_account.efs.performance_mode
  throughput_mode                 = local.yaml_vars.workload_account.efs.throughput_mode


  # File system policy
  attach_policy                      = true
  bypass_policy_lockout_safety_check = false
  policy_statements = [
    {
      sid = "efs-policy-prevent-anonymous-acces"
      effect = "Allow"
      principals = [{
        type = "AWS"
        identifiers = ["*"]
      }]
      actions = [
        "elasticfilesystem:ClientRootAccess",
        "elasticfilesystem:ClientWrite"
      ]
      condition = [{
        test     = "Bool"
        variable = "elasticfilesystem:AccessedViaMountTarget"
        values   = ["true"]
      }]
    },
    {
      sid = "efs-policy-allow-acces"
      effect = "Allow"
      principals = [{
        type = "AWS"
        identifiers = [aws_iam_role.node_group.arn]
      }]
      actions = ["elasticfilesystem:Client*"]
      conditions =  [{
        test     = "Bool"
        variable = "elasticfilesystem:AccessedViaMountTarget"
        values   = ["true"]
      }]
    }
  ]

  # Mount targets / security group
  mount_targets              = local.mount_targets
  security_group_description = "EFS security group"
  security_group_vpc_id      = local.yaml_vars.workload_account.vpc.vpc_id
  security_group_rules = {
    vpc = {
      # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = local.private_subnets_cidr_blocks
    }
  }

  # Access point(s)
  access_points = {
    posix_example = {
      name = "posix-example"
      posix_user = {
        gid            = 1000
        uid            = 1000
        secondary_gids = [1001]
      }

      tags = {
        Additionl = "yes"
      }
    }
    root_example = {
      root_directory = {
        path = "/"
        creation_info = {
          owner_gid   = 1000
          owner_uid   = 1000
          permissions = "755"
        }
      }
    }

    shared_cce = {
      root_directory = {
        path = "/shared"
        creation_info = {
          owner_gid   = 1000
          owner_uid   = 1000
          permissions = "755"
        }
      }
    }
  }

  # Backup policy
  enable_backup_policy = true

  # Replication configuration
  create_replication_configuration = false

  tags = local.tags

  depends_on = [
    aws_iam_role.node_group,
  ]
}
