# Example Output - URL of the Website
output "website_url" {
  value = "http://${aws_s3_bucket.portfolio_website.website_endpoint}"
}

