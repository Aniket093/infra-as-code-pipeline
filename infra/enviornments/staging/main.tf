module "vpc" {
  source = "../../modules/vpc"

  cidr_block           = var.cidr_block
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "sg" {
  source = "../../modules/security_groups"

  vpc_id   = module.vpc.vpc_id
  app_port = var.app_port
}

module "ecr" {
  source = "../../modules/ecr"

  repo_name = var.repo_name
}

module "iam" {
  source = "../../modules/iam"

  role_name = "ecsTaskExecutionRole-staging"
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  log_group_name    = var.log_group_name
  retention_in_days = 14
}

module "alb" {
  source = "../../modules/alb"

  vpc_id            = module.vpc.vpc_id
  subnets           = module.vpc.public_subnet_ids
  security_group_id = module.sg.alb_sg_id
  app_port          = var.app_port
}

module "ecs" {
  source = "../../modules/ecs"

  cluster_name       = var.cluster_name
  subnets            = module.vpc.private_subnet_ids
  security_group     = module.sg.ecs_sg_id
  target_group_arn   = module.alb.target_group_arn
  ecr_image          = module.ecr.repository_url
  execution_role_arn = module.iam.execution_role_arn
  log_group_name     = module.cloudwatch.log_group_name
  region             = var.region
}
