variable "bucket_name" {
  description = "Prefix for the name of the S3 bucket used to store Terraform state. The Environment tag value is appended to it. Must result in a globally unique bucket name."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be a valid S3 bucket name (lowercase letters, numbers, dots, hyphens, 3-63 chars)."
  }
}

variable "force_destroy" {
  description = "Whether to allow the state bucket to be destroyed even if it still contains objects. Set to false in production."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to apply to all resources created by this module. Must include an Environment key."
  type        = map(string)

  validation {
    condition     = contains(keys(var.tags), "Environment")
    error_message = "tags must include an \"Environment\" key."
  }
}
