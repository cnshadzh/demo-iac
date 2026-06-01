variable "config_name" {
  description = "The name of the tlz config, located under folder config"
  type        = string
  default     = "config.yaml"
}

variable "eks_config_name" {
  description = "The name of the tlz config, located under folder config"
  type        = string
  default     = "eks.yaml"
}

variable "environment" {
  description = "environment"
  type        = string
  default     = "dev"
}

variable "product" {
  description = "product"
  type        = string
  default     = "product"
}

variable "region" {
  description = "The name of the region"
  type        = string
  default     = "eu-central-1"
}

variable "global_config_name" {
  description = "The name of the landing zone global config, located under folder config"
  type        = string
  default     = "config.yaml"
}

variable "account" {
  description = "account"
  type        = string
  default     = "demo"
}