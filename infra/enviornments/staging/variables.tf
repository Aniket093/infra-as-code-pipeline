variable "cidr_block" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "repo_name" {
  type = string
}

variable "log_group_name" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "app_port" {
  type    = number
  default = 80
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.1.3.0/24", "10.1.4.0/24"]
}
