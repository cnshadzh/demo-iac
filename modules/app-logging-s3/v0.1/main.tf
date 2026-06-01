# Terraform module which creates S3 Bucket resources for Access Log on AWS.
#
# https://docs.aws.amazon.com/AmazonS3/latest/dev/ServerLogs.html

# https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
resource "aws_s3_bucket" "default" {
  # Rules for Bucket Naming
  #   - Bucket names must be unique across all existing bucket names in Amazon S3.
  #   - Bucket names must comply with DNS naming conventions.
  #   - Bucket names must be at least 3 and no more than 63 characters long.
  #   - Bucket names can contain lowercase letters, numbers, and hyphens.
  #   - Bucket names must not contain uppercase characters or underscores.
  #   - Bucket names must start with a lowercase letter or number.
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html#bucketnamingrules
  bucket = var.s3_name

  # A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error.
  # These objects are not recoverable.
  # https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#force_destroy
  force_destroy = var.force_destroy

  # A mapping of tags to assign to the bucket.
  tags = var.tags
}

data "aws_canonical_user_id" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

// https://docs.aws.amazon.com/zh_cn/AmazonS3/latest/userguide/enable-server-access-logging.html
// replace acl with bucket policy
data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid    = "S3ServerAccessLogsPolicy"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = ["${aws_s3_bucket.default.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid    = "AllowLoggingOperator"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${var.cluster_name}-${data.aws_region.current.name}-logging-operator-sa-role"]
    }

    actions = ["s3:PutObject*", "s3:GetObject*", "s3:ListBucket"]

    resources = ["${aws_s3_bucket.default.arn}", "${aws_s3_bucket.default.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "destination_bucket_policy" {
  bucket = aws_s3_bucket.default.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

// resource "aws_s3_bucket_ownership_controls" "default" {
//   bucket = aws_s3_bucket.default.id
//
//   rule {
//     object_ownership = "ObjectWriter"
//   }
// }
//
// resource "aws_s3_bucket_acl" "default" {
//   bucket = aws_s3_bucket.default.id
//   # S3 access control lists (ACLs) enable you to manage access to buckets and objects.
//   # https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html
//   #
//   # Server access logging provides detailed records for the requests that are made to a bucket.
//   # S3 uses a special log delivery account, called the Log Delivery group, to write access logs.
//   # Server access log records are delivered on a best effort basis.
//   # https://docs.aws.amazon.com/AmazonS3/latest/dev/ServerLogs.html
//   access_control_policy {
//      grant {
//       grantee {
//         id   = data.aws_canonical_user_id.current.id
//         type = "CanonicalUser"
//       }
//       permission = "FULL_CONTROL"
//     }
//     grant {
//       grantee {
//           type = "Group"
//           uri  = "http://acs.amazonaws.com/groups/s3/LogDelivery"
//       }
//       permission = "READ_ACP"
//     }
//     grant {
//       grantee {
//           type = "Group"
//           uri  = "http://acs.amazonaws.com/groups/s3/LogDelivery"
//       }
//       permission = "WRITE"
//     }
//     owner {
//         id = data.aws_canonical_user_id.current.id
//     }
//   }
//
// }

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.default.bucket
  # S3 encrypts your data at the object level as it writes it to disks in its data centers
  # and decrypts it for you when you access it.
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/serv-side-encryption.html
  rule {
    apply_server_side_encryption_by_default {
      # The objects are encrypted using server-side encryption with either
      # Amazon S3-managed keys (SSE-S3) or AWS KMS-managed keys (SSE-KMS).
      # https://docs.aws.amazon.com/AmazonS3/latest/dev/bucket-encryption.html
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "default" {
  bucket = aws_s3_bucket.default.id
  # To manage your objects so that they are stored cost effectively throughout their lifecycle, configure their lifecycle.
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/object-lifecycle-mgmt.html
  rule {
    id = "default"
    status  = var.lifecycle_rule_enabled

    # The STANDARD_IA and ONEZONE_IA storage classes are designed for long-lived and infrequently accessed data.
    # https://docs.aws.amazon.com/AmazonS3/latest/dev/storage-class-intro.html#sc-infreq-data-access
    transition {
      days          = var.standard_ia_transition_days
      storage_class = "STANDARD_IA"
    }

    # The GLACIER storage class is suitable for archiving data where data access is infrequent.
    # https://docs.aws.amazon.com/AmazonS3/latest/dev/storage-class-intro.html#sc-glacier
    transition {
      days          = var.glacier_transition_days
      storage_class = "GLACIER"
    }

    # For a versioned bucket, there are several considerations that guide how Amazon S3 handles the expiration action.
    #   - The Expiration action applies only to the current version.
    #   - S3 doesn't take any action if there are one or more object versions and the delete marker is the current version.
    #   - If the current object version is the only object version and it is also a delete marker,
    #     S3 removes the expired object delete marker.
    # https://docs.aws.amazon.com/AmazonS3/latest/dev/intro-lifecycle-rules.html
    expiration {
      days = var.expiration_days
    }

    # Specifies when noncurrent objects transition to a specified storage class.
    # https://docs.aws.amazon.com/AmazonS3/latest/dev/intro-lifecycle-rules.html#intro-lifecycle-rules-actions
    noncurrent_version_transition {
      noncurrent_days          = var.glacier_noncurrent_version_transition_days
      storage_class = "GLACIER"
    }

    # Specifies when noncurrent object versions expire.
    # https://docs.aws.amazon.com/AmazonS3/latest/dev/intro-lifecycle-rules.html#intro-lifecycle-rules-actions
    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }
  }
}