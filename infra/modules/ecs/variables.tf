variable "cluster_name" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "security_group" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "ecr_image" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "log_group_name" {
  type = string
}

variable "region" {
  type = string
}

variable "app_port" {
  type    = number
  default = 80
}

variable "desired_count" {
  type    = number
  default = 2
}