variable "product_name" {
  type        = string
  description = "Project name for sops kms key"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the bucket."
}

variable "environment_list" {
  description = "Environment name (production/uat/lt/stage/dev/test)"
  type        = list
  default     = []
}

variable "account_id" {
  description = "The application's account id"
  type        = string
  default     = ""
}

variable "keyreader_iamrole" {
  description = "Argocd iamrole for access kms key"
  type        = list
  default     = []
}

variable "cluster_ids" {
  type        = list
  default     = []
  description = "Cluster ids"
}
