output "load_balancer_ip" {
  value = aws_lb.default.dns_name
}

output "AWS_ECR" {
  value = aws_ecr_repository.spring-petclinic.repository_url
}

output "ECS_CLUSTER_NAME" {
  value = aws_ecs_cluster.main.name
}

output "ECS_SERVICE_NAME" {
  value = aws_ecs_service.pet_clinic.name
}
