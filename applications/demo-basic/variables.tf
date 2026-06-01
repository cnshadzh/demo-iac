variable "config_name" {
  description = "The name of the tlz config, located under folder config"
  type        = string
  default     = "config.yaml"
}

variable "region" {
  description = "The region of the tlz config, located under folder config"
  type        = string
  default     = "eu-central-1"
}

variable "environment" {
  description = "environment"
  type        = string
  default     = "dev"
}

variable "account" {
  description = "account"
  type        = string
  default     = "demo"
}
