output "registry_id" {
  value = aws_ecr_repository.ecr.registry_id
}

output "repository_url" {
  value = aws_ecr_repository.ecr.repository_url
}

output "arn" {
  value = aws_ecr_repository.ecr.arn
}

output "repo_name" {
  value = aws_ecr_repository.ecr.name
}