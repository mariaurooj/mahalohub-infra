output "ecr_id" {
  value = aws_ecr_repository.repo.id
}

output "ecr_url" {
  value = aws_ecr_repository.repo.repository_url
}
