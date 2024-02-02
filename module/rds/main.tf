resource "random_password" "master_password" {
  length = 16
  special = false
}

resource "aws_ssm_parameter" "master_password" {
  name = "/${var.prefix.environment}/${var.rds.identifier}/master_password"
  description = "Master password for RDS"
  value  = random_password.master_password.result
  type = "SecureString"
}

resource "aws_db_subnet_group" "rds_sbg" {
  name       = lower(format("%s-%s-frontend-rds-subnet-group", var.prefix.name, var.prefix.environment))
  subnet_ids = var.subnets

  tags = {
    Name        = lower(format("%s-%s-frontend-rds-subnet-group", var.prefix.name, var.prefix.environment))
    Environment = var.prefix.environment
  }
}

resource "aws_security_group" "rds_postgres_sg" {
  name        = "${var.prefix.environment}-${var.prefix.name}-rds-sg"
  description = "Allow access to the RDS database instance."
  vpc_id      = var.vpc_id

  ingress {
    protocol  = "tcp"
    from_port = 5432
    to_port   = 5432
    security_groups = [
      var.ecs_tasks_sg,
      var.sg
    ]
  }

  egress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    security_groups = [
      var.ecs_tasks_sg,
      var.sg
    ]
  }

  tags = {
    Name        = "${var.prefix.environment}-${var.prefix.name}-rds-postgres-sg"
    Environment = var.prefix.environment
    Terraform   = "Yes"
  }
}

resource "aws_db_instance" "rds" {
  identifier                   = var.rds.identifier
  allocated_storage            = var.rds.allocated_storage
  storage_type                 = var.rds.storage_type
  engine                       = var.rds.engine
  engine_version               = var.rds.engine_version
  instance_class               = var.rds.instance_class
  db_name                      = var.rds.db_name
  username                     = var.rds.username
  password                     = aws_ssm_parameter.master_password.value
  #parameter_group_name         = var.rds.parameter_group_name
  skip_final_snapshot          = var.rds.skip_final_snapshot
  publicly_accessible          = var.rds.publicly_accessible
  multi_az                     = var.rds.multi_az
  backup_retention_period      = var.rds.backup_retention_period
  backup_window                = var.rds.backup_window
  auto_minor_version_upgrade   = var.rds.auto_minor_version_upgrade
  #performance_insights_enabled = var.rds.performance_insights_enabled
  allow_major_version_upgrade  = var.rds.allow_major_version_upgrade
  vpc_security_group_ids       = [aws_security_group.rds_postgres_sg.id]
  db_subnet_group_name         = aws_db_subnet_group.rds_sbg.name

  tags = {
    Name        = lower(format("%s_%s_rds", var.prefix.name, var.prefix.environment))
    Environment = var.prefix.environment
  }
}
