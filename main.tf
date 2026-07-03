data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

locals {
  environment = lower(var.tags["Environment"])
  bucket_name = "${var.bucket_name}-${local.environment}"
}

# ---------------------------------------------------------------------------
# KMS key used to encrypt the Terraform state bucket
# ---------------------------------------------------------------------------

resource "aws_kms_key" "terraform_state" {
  description             = "Encrypts the Terraform state S3 bucket (${local.bucket_name})"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableRootAccountAccess"
        Effect    = "Allow"
        Principal = { AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      }
    ]
  })

  tags = var.tags
}

resource "aws_kms_alias" "terraform_state" {
  name          = "alias/terraform-state-${local.environment}"
  target_key_id = aws_kms_key.terraform_state.key_id
}

# ---------------------------------------------------------------------------
# S3 bucket used to store Terraform state
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "terraform_state" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.terraform_state.arn
    }
    bucket_key_enabled = true
  }
}

# ---------------------------------------------------------------------------
# Secrets Manager secret for infrastructure-level secrets
# ---------------------------------------------------------------------------

resource "aws_secretsmanager_secret" "infrastructure" {
  name = "${local.environment}/infrastructure"

  tags = var.tags
}
