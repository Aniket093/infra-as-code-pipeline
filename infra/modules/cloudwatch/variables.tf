variable "log_group_name" {
  description = "CloudWatch log group name"
  type        = string
}

variable "retention_in_days" {
  description = "Log retention period"
  type        = number
  default     = 7
}