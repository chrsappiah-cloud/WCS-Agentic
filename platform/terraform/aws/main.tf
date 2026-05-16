# AWS ECS Fargate sketch for WCS Agentic platform (orchestrator + worker + Vapor API)
terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "wcs-agentic"
}

# Extend with VPC, ECS cluster, ALB, ECR repos, secrets manager, RDS Postgres.
# This file is a starting point — run `terraform init && terraform plan` after filling remote state.

output "next_steps" {
  value = <<-EOT
    1. Push images to ECR (orchestrator, onboarding-worker, vapor-api)
    2. Create ECS task definitions with env: OPA_URL, VAPOR_URL, WORKER_URL
    3. Wire ALB :443 → orchestrator :3000, :8080 → vapor
    4. Store secrets in AWS Secrets Manager (DB, JWT)
  EOT
}
