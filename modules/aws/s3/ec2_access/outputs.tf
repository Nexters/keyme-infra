output "domain_name" {
  value = aws_s3_bucket.s3.bucket_regional_domain_name
}

output "arn" {
  value = aws_s3_bucket.s3.arn
}

output "bucket_name" {
  value = aws_s3_bucket.s3.bucket
}
