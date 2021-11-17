
resource "aws_ecs_task_definition" "pet_clinic" {
  family                   = "pet-clinic-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  task_role_arn            = "${aws_iam_role.petclinc-role.arn}"
  execution_role_arn       = "${aws_iam_role.ecs_task_execution_role.arn}"

  container_definitions = jsonencode([
    {
      "image" = "${aws_ecr_repository.spring-petclinic.repository_url}:latest"
      "cpu" = 1024
      "memory" = 2048
      "name" = "pet-clinic-app"
      "networkMode" = "awsvpc"
      "portMappings" = [
        {
          "containerPort" = 8080
          "hostPort" = 8080
        }
      ]
    }
  ])
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
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.pet_clinic]
}