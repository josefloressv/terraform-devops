# Output variable definitions

output "arn" {
  description = "ARN of the bucket"
  value       = aws_s3_bucket.s3_bucket.arn
}

output "name" {
  description = "Name (id) of the bucket"
  value       = aws_s3_bucket.s3_bucket.id
}

output "url" {
    description = "Bucket website endpoint"
    value = format("%s%s%s%s%s","http://", aws_s3_bucket.s3_bucket.id, ".", aws_s3_bucket.s3_bucket.website_domain, "/index.html")
}