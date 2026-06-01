
### Define the default aws provider
provider "aws" {
  region              = "${var.region}"
  allowed_account_ids = ["984601295324"]
}


### Define terraform version and required providers
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}
