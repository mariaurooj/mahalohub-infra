output "rds_password_arn" {
  value = aws_ssm_parameter.master_password.arn
}

output "rds_endpoint" {
  value = aws_db_instance.rds.endpoint
}

output "rds_port" {
  value = aws_db_instance.rds.port
}

output "db_name" {
  value = aws_db_instance.rds.db_name
}

output "db_user" {
  value = aws_db_instance.rds.username
}

