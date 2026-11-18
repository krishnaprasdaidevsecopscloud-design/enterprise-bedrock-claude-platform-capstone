terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # FinOps Governance: Automatically enforce mandatory tags on every AWS resource
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      CostCenter  = var.cost_center
      Owner       = var.owner_email
      ManagedBy   = "Terraform"
    }
  }
}
