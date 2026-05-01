variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "app_port" {
  description = "Application port (container port)"
  type        = number
  default     = 80
}