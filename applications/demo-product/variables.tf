# basic
variable "global_config_name" {
  description = "The name of the landing zone global config, located under folder config"
  type        = string
  default     = "config.yaml"
}

variable "eks_config_name" {
  description = "The name of the tlz config, located under folder config"
  type        = string
  default     = "eks.yaml"
}

variable "environment" {
  description = "environment name"
  type        = string
  default     = "dev"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the project."
}

variable "config_name" {
  description = "The name of the tlz config, located under folder config"
  type        = string
  default     = "config.yaml"
}

variable "region" {
  description = "The application's account region"
  type        = string
  default     = "eu-central-1"
}

variable "account" {
  description = "account"
  type        = string
  default     = "demo"
}

variable "product" {
  description = "product"
  type        = string
  default     = "renren"
}

# product resources
variable "redis" {
  description = "commons project redis"
  default     = {}
  type        = any
}

variable "rds" {
  description = "commons project rds"
  default     = {}
  type        = any
}


variable "rds_sg" {
  description = "RDS security group id"
  type        = string
  default     = ""
}

variable "cluster_parameters" {
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default     = []
  description = "List of DB parameters to apply"
}