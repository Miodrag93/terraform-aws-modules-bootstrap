# terraform-aws-modules-bootstrap

Bootstraps the AWS resources needed to host Terraform remote state: an S3
bucket (versioned, encrypted, private) and a dedicated KMS key used to
encrypt it.

State locking uses S3's native conditional-write locking
(`use_lockfile = true`, Terraform >= 1.10) — no DynamoDB table is required.

## Usage

```hcl
module "bootstrap" {
  source = "github.com/<org>/terraform-aws-modules-bootstrap"

  bucket_name = "my-org-terraform-state"

  tags = {
    Environment = "shared"
  }
}
```

The `Environment` tag value is appended to the bucket name and KMS alias, so
the example above creates the bucket `my-org-terraform-state-shared` and the
KMS alias `alias/terraform-state-shared`.

Then configure your backend to use the created bucket and key:

```hcl
terraform {
  backend "s3" {
    bucket       = "my-org-terraform-state-shared"
    key          = "path/to/my/state.tfstate"
    region       = "us-east-1"
    encrypt      = true
    kms_key_id   = "alias/terraform-state-shared"
    use_lockfile = true
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.10 |
| aws | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| bucket\_name | Prefix for the S3 bucket name; the Environment tag value is appended to it. Result must be globally unique. | `string` | n/a | yes |
| force\_destroy | Whether to allow the state bucket to be destroyed even if it still contains objects. Set to false in production. | `bool` | `false` | no |
| tags | A map of tags to apply to all resources created by this module. Must include an Environment key. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| s3\_bucket\_name | Name of the S3 bucket storing Terraform state. |
| s3\_bucket\_arn | ARN of the S3 bucket storing Terraform state. |
| kms\_key\_id | ID of the KMS key used to encrypt the Terraform state bucket. |
| kms\_key\_arn | ARN of the KMS key used to encrypt the Terraform state bucket. |
| kms\_key\_alias | Alias of the KMS key used to encrypt the Terraform state bucket. |
| secrets\_manager\_secret\_arn | ARN of the Secrets Manager secret for infrastructure-level secrets. |

## Resources created

- `aws_s3_bucket` — the state bucket (versioned, SSE-KMS encrypted)
- `aws_kms_key` / `aws_kms_alias` — dedicated CMK used for SSE-KMS on the bucket
- `aws_secretsmanager_secret` — secret container named `<environment>/infrastructure`

Public access block and ACL-disabled ownership are AWS's default for
newly created buckets, so this module does not declare them explicitly.
