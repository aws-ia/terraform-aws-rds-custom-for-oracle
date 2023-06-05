
output "endpoint_security_group_id" {
  value = var.create_endpoint_security_group ? aws_security_group.vpc_endpoint_sg[0].id : var.endpoint_security_group_id
}

