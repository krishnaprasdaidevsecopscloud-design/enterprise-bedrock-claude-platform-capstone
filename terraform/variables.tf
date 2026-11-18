variable "aws_region" {
  description = "AWS region supporting Amazon Bedrock and Anthropic Claude"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "enterprise-bedrock-claude"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "cost_center" {
  description = "FinOps billing code for AI workloads"
  type        = string
  default     = "CC-AI-PLATFORM-01"
}

variable "owner_email" {
  type    = string
  default = "platform-lead@example.com"
}

variable "monthly_token_alarm_threshold" {
  description = "FinOps threshold for daily input tokens to prevent runaway bills"
  type        = number
  default     = 1000000
}
