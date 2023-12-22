# Provider Configuration
# Specifies the AWS provider and sets the region to Northern California (us-west-1)
provider "aws" {
  region = "us-west-1"
}

# S3 Bucket for Website Hosting
# Creates an S3 bucket to host the static website. 
# The bucket is configured for website hosting with specified index and error documents.
resource "aws_s3_bucket" "portfolio_website" {
  bucket = "jalexanderelliot-portfolio-website"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

# Dynamically Upload HTML Files to S3 Bucket
# Uploads the HTML files located in the 'html/' directory to the S3 bucket.
resource "aws_s3_bucket_object" "html_files" {
  for_each = fileset(var.html_files_path, "*.html")

  content {
    bucket       = aws_s3_bucket.portfolio_website.id
    key          = each.value
    source       = "${var.html_files_path}/${each.value}"
    acl          = "public-read"
    content_type = "text/html"
    etag         = filemd5("${var.html_files_path}/${each.value}")
  }
}

# Route53 Domain and Record
# Configures DNS settings for the domain using Route53. Assumes domain is already registered.
resource "aws_route53_zone" "primary" {
  name = "jalexanderelliot.xyz"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.jalexanderelliot.xyz"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

# CloudFront Distribution
# Sets up a CloudFront distribution for the website. Configures the origin to the S3 bucket.
# Implements geo-restriction to allow access only from specified countries.
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.portfolio_website.bucket_regional_domain_name
    origin_id   = "S3-Origin"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-Origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "MX", "CA", "EU", "AU"]  # Geographical restrictions
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

