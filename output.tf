output "ecs_service_id" {
  value = aws_ecs_service.task.id
}

output "privateipv4" {
  value = coalesce(data.aws_network_interface.task[*].private_ip)
}

output "publicipv4" {
  value = join(",", data.aws_network_interface.task[*].association[0].public_ip)
}

output "dns_name" {
  value = "${var.name}.${data.aws_route53_zone.task.name}"
}
