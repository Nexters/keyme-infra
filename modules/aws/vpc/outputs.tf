output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnets_ids" {
  value = values(aws_subnet.public_subnets)[*].id
}

output "private_subnets_ids" {
  value = values(aws_subnet.private_subnets)[*].id
}