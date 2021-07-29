# Output definitions
output "website_bucket_arn" {
  description = "ARN of the bucket"
  value       = module.website_s3_bucket.arn
}

output "website_bucket_url" {
  description = "Public URL of the bucket"
  value       = module.website_s3_bucket.url
}