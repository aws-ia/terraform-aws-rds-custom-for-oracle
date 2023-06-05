output "iam_instance_profile_name" {
  description = "RDS IAM instance profile."
  value       = local.iam_instance_profile_name
}

output "iam_role" {
  description = "RDS IAM role."
  value       = local.iam_role_name
}

output "db_subnet_group" {
  description = "RDS DB subnet group."
  value       = local.db_subnet_group
}

output "aws_db_instance_primary_attributes" {
  description = "DBInstance resource attributes. Full output of aws_db_instance."
  value       = {for k,v in aws_db_instance.primary: k => v if k != "password" }
}

output "aws_db_instance_replicas_attributes" {
  description = "DBInstance resource attributes. Full output of aws_db_instance."
  value       = {for k,v in aws_db_instance.replicas: k => v if k != "password" }
}
