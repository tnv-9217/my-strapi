provider "aws" {
  region = "us-east-1"  # Specify your desired region
}

resource "aws_ecr_repository" "strapi_repo" {
  name = "strapi-repo-tnv"
}

resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-cluster-image"
}

resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "strapi-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::*******78173:role/ecsTaskExecutionRole"  # Specify your existing role ARN

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = "*******78173.dkr.ecr.us-east-1.amazonaws.com/strapi-repo-tnv:latest"
      essential = true
      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "strapi_service" {
  name            = "strapi-service-tnv"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    subnets         = ["subnet-004bb278********"]  # Specify your subnet IDs
    security_groups = [aws_security_group.strapi_sg.id]
    assign_public_ip = true
  }
}

resource "aws_security_group" "strapi_sg" {
  name        = "strapi-image-sg"
  description = "Allow HTTP traffic"
  vpc_id      = "vpc-0c04e74d******"  # Specify your VPC ID

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route53_record" "strapi_record" {
  zone_id = "Z0660702********"  # Specify your hosted zone ID
  name    = "tnv.contentecho.in"
  type    = "A"
  ttl     = 300

  records = [aws_eip.strapi_eip.public_ip]
}

resource "aws_eip" "strapi_eip" {
  vpc = true

  depends_on = [
    aws_ecs_service.strapi_service,
  ]
}
