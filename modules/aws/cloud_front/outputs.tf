output "url" {
  value = aws_cloudfront_distribution.distribution.domain_name
}

output "arn" {
  value = aws_cloudfront_distribution.distribution.arn
}