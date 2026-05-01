#ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

#Task Definition
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.cluster_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name  = "app"
      image = var.ecr_image

      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
        }
      ]

      essential = true

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

#ECS Service (Connected to ALB)
resource "aws_ecs_service" "this" {
  name            = "${var.cluster_name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = var.subnets
    security_groups  = [var.security_group]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "app"
    container_port   = var.app_port
  }

  depends_on = [
    aws_ecs_task_definition.this
  ]
}

