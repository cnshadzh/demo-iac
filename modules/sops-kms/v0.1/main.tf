locals {
    kms_policy = <<POLICY
{
    "Id": "key-consolepolicy-3",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:${data.aws_partition.current.partition}:iam::${var.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": ${jsonencode([
                 for r in var.keyreader_iamrole:
                   r
              ])}
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": ${jsonencode([
                 for r in var.keyreader_iamrole:
                   r
              ])}
            },
            "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_kms_key" "products" {
  for_each                 = toset(var.environment_list)
  description              = "product ${var.product_name} sops kms key"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true
  is_enabled               = true
  policy                   = local.kms_policy

  tags                     = var.tags
}

resource "aws_kms_alias" "products" {
  for_each                 = toset(var.environment_list)
  name                     = "alias/${var.product_name}-${each.key}-product"
  target_key_id            = aws_kms_key.products[each.key].key_id
}


resource "aws_kms_key" "clusters" {
  for_each                 = toset(var.cluster_ids)
  description              = "Application ${each.key} sops kms key"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true
  is_enabled               = true
  policy                   = local.kms_policy

  tags                     = var.tags
}

resource "aws_kms_alias" "clusters" {
  for_each                 = toset(var.cluster_ids)
  name                     = "alias/${each.key}-cluster"
  target_key_id            = aws_kms_key.clusters[each.key].key_id
}
