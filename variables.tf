variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "cloudtrail-demo"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "log_retention_days" {
  description = "Days to retain CloudTrail logs in S3 (compliance requirement)"
  type        = number
  default     = 365  # 1 year for compliance

  validation {
    condition     = var.log_retention_days >= 90
    error_message = "Logs must be retained for at least 90 days for compliance."
  }
}

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch Logs integration for real-time monitoring"
  type        = bool
  default     = false  # Set to true if you want real-time log analysis
}
