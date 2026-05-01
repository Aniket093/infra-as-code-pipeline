variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnets" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "ALB security group"
  type        = string
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Health check endpoint"
  type        = string
  default     = "/"
}
