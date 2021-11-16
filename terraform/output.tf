output "erc_url" {
  value = aws_ecr_repository.spring-petclinic.repository_url
}

output "load_balancer_ip" {
  value = aws_lb.default.dns_name
}
