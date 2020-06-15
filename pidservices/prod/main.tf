resource "aws_s3_bucket" "pidservices" {
    bucket = "pidservices.org"
    acl = "public-read"
    policy = templatefile("s3_cloudfront.json", {
      bucket_name = "pidservices.org"
    })

    website {
        index_document = "index.html"
    }

    tags = {
        Name = "pidservices"
    }

    versioning {
        enabled = true
    }
}

resource "aws_cloudfront_origin_access_identity" "pidservices_org" {}

resource "aws_cloudfront_distribution" "pidservices" {
  origin {
    domain_name = aws_s3_bucket.pidservices.bucket_domain_name
    origin_id   = "pidservices.org"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.pidservices_org.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  custom_error_response {
    error_code            = "404"
    error_caching_min_ttl = "5"
    response_code         = "200"
    response_page_path    = "/index.html"
  }

  aliases = ["pidservices.org", "www.pidservices.org"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "pidservices.org"

    forwarded_values {
      query_string = false

      cookies {
        forward = "whitelist"
        whitelisted_names = ["_datacite_jwt"]
      }
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
    acm_certificate_arn = data.aws_acm_certificate.cloudfront-pidservices.arn
    ssl_support_method  = "sni-only"
  }
}


resource "aws_route53_record" "apex" {
    zone_id = data.aws_route53_zone.pidservices.zone_id
    name = "pidservices.org"
    type = "A"
    alias {
      name = aws_cloudfront_distribution.pidservices.domain_name
      zone_id = var.cloudfront_alias_zone_id
      evaluate_target_health = true
    }
}

resource "aws_route53_record" "www" {
    zone_id = data.aws_route53_zone.pidservices.zone_id
    name = "www.pidservices.org"
    type = "CNAME"
    ttl = "300"
    records = [ aws_cloudfront_distribution.pidservices.domain_name ]
}