resource "aws_ecs_cluster" "default" {
  name       = "${var.prefix.environment}-${var.prefix.name}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.prefix.environment}-${var.prefix.name}-ecs-frontend-cluster"
    Environment = var.prefix.environment
    Terraform   = "Yes"
  }
}
