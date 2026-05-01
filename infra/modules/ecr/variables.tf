variable "repo_name" {
  description = "ECR repository name"
  type        = string
}

variable "image_tag_mutability" {
  description = "IMMUTABLE or MUTABLE"
  type        = string
  default     = "IMMUTABLE"
}

