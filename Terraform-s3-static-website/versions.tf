# Specify Terraform version and provider versions
terraform {
  required_version = "~> 1.6.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

