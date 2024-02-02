resource "aws_ecr_repository" "repo" {
  name                 = "${var.prefix.environment}-${var.prefix.name}-${var.ecr.name}"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name        = "${var.prefix.environment}-${var.prefix.name}-${var.ecr.name}"
    Environment = var.prefix.environment
    Terraform   = "Yes"
  }
}
# ECR Lifecycle Policy Settings
resource "aws_ecr_lifecycle_policy" "repo" {
  repository = aws_ecr_repository.repo.name
  policy = jsonencode({
    rules = [{
      rulePriority = var.ecr.rulePriority
      description  = var.ecr.description
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = var.ecr.countType
        countNumber = var.ecr.countNumber
      }
    }]
  })
}

