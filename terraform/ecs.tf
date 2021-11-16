resource "aws_ecs_task_definition" "pet_clinic" {
  family                   = "pet-clinic-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048

  container_definitions = jsonencode([
    {
      "image" = "${aws_ecr_repository.spring-petclinic.repository_url}"
      "cpu" = 1024
      "memory" = 2048
      "name" = "pet-clinic-app"
      "networkMode" = "awsvpc"
      "portMappings" = [
        {
          "containerPort" = 3000
          "hostPort" = 3000
        }
      ]
    }
  ])
}

resource "aws_security_group" "pet_clinic_task" {
  name        = "petclinic-task-security-group"
  vpc_id      = aws_vpc.default.id

  ingress {
    protocol        = "tcp"
    from_port       = 3000
    to_port         = 3000
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "main" {
  name = "petclinic-cluster"
}

resource "aws_ecs_service" "pet_clinic" {
  name            = "pet-clinic-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.pet_clinic.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.pet_clinic_task.id]
    subnets         = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.pet_clinic.id
    container_name   = "pet-clinic-app"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.pet_clinic]
}