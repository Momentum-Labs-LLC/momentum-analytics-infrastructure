provider "aws" {
  region = local.region
}

locals {
  env         = "prd"
  corp        = "momentum"
  iteration   = 0
  region      = "us-east-1"
  project     = "analytics"
  subproject  = "cdn"
  name_prefix = "${local.corp}-${local.env}-${local.project}-${local.subproject}"

  tags = {
    Production = "true"
    Project    = "${local.project}-${local.subproject}"
  }
}

resource "aws_s3_bucket" "this-bucket" {
  bucket = "${local.name_prefix}-${local.iteration}"

  tags = merge(local.tags,
    tomap(
      {
        "Name" = "${local.name_prefix}-${local.iteration}"
      }
  ))
}

resource "aws_s3_bucket_ownership_controls" "this-cdn-controls" {
  bucket = aws_s3_bucket.this-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


resource "aws_cloudfront_origin_access_control" "this-distribution-oac" {
  name                              = "${local.name_prefix}-oac-${local.iteration}"
  description                       = "Read Only Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_s3_bucket_policy" "this-cdn-bucket-access-policy" {
  bucket = aws_s3_bucket.this-bucket.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : {
        "Sid" : "AllowCloudFrontServicePrincipalReadOnly",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : "s3:GetObject",
        "Resource" : "${aws_s3_bucket.this-bucket.arn}/*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : aws_cloudfront_distribution.this-distribution.arn
          }
        }
      }
    }
  )
}

data "aws_acm_certificate" "cert" {
  domain   = "mll-analytics.com"
  statuses = ["ISSUED"]
}

resource "aws_cloudfront_distribution" "this-distribution" {
  aliases = ["mll-analytics.com"]

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
    #cloudfront_default_certificate = true
  }

  origin {
    origin_id                = aws_s3_bucket.this-bucket.id
    domain_name              = aws_s3_bucket.this-bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this-distribution-oac.id
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = "Testing distribution"

  default_cache_behavior {
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.this-bucket.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_s3_bucket.this-bucket.id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.this-bucket.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US"]
    }
  }

  tags = local.tags
}

data "aws_route53_zone" "mll-analytics-zone" {
  name = "mll-analytics.com"
}

resource "aws_route53_record" "analytics-ns" {
  zone_id = data.aws_route53_zone.mll-analytics-zone.zone_id
  name    = "mll-analytics.com"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.this-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.this-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}