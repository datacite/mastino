resource "aws_s3_bucket" "design" {
    bucket = "design.datacite.org"
    acl = "public-read"
    policy = data.template_file.design.rendered
    website {
        index_document = "index.html"
        error_document = "404.html"
    }
    cors_rule {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT", "POST"]
      allowed_origins = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
    tags = {
        Name = "design"
    }
    versioning {
      enabled = true
    }

     server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.mykey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "design" {
  bucket = aws_s3_bucket.design.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation= true
}


resource "aws_cloudfront_distribution" "design" {
  origin {
    domain_name = aws_s3_bucket.design.website_endpoint
    origin_id   = "design.datacite.org"

    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port = "80"
      https_port = "443"
      origin_ssl_protocols = ["TLSv1"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = data.aws_s3_bucket.logs.bucket_domain_name
    prefix          = "design/"
  }

  aliases = ["design.datacite.org"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "design.datacite.org"

    forwarded_values {
      query_string = false

      cookies {
        forward = "whitelist"
        whitelisted_names = ["_datacite_jwt"]
      }

      headers = ["Host", "Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method", "Access-Control-Allow-Origin"]
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "prod"
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.cloudfront.arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_route53_record" "design" {
   zone_id = data.aws_route53_zone.production.zone_id
   name = "design.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [aws_cloudfront_distribution.design.domain_name]
}

resource "aws_route53_record" "split-design" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "design.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [aws_cloudfront_distribution.design.domain_name]
}