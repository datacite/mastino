resource "aws_s3_bucket" "demorepo-stage" {
    bucket = "demorepo.stage.datacite.org"
    acl = "public-read"
    policy = templatefile("s3_cloudfront.json", {
      bucket_name = "demorepo.stage.datacite.org"
    })

    website {
        index_document = "index.html"
    }

    tags = {
        Name = "DemoRepoStage"
    }
}

resource "aws_cloudfront_distribution" "demorepo-stage" {
  origin {
    domain_name = aws_s3_bucket.demorepo-stage.website_endpoint
    origin_id   = "demorepo.stage.datacite.org"

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
    bucket          = data.aws_s3_bucket.logs-stage.bucket_domain_name
    prefix          = "demorepo/"
  }

  aliases = ["demorepo.stage.datacite.org"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "demorepo.stage.datacite.org"

    forwarded_values {
      query_string = true

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
    Environment = "stage"
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.cloudfront-stage.arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_route53_record" "demorepo-stage" {
   zone_id = data.aws_route53_zone.production.zone_id
   name = "demorepo.stage.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [aws_cloudfront_distribution.demorepo-stage.domain_name]
}

resource "aws_route53_record" "split-demorepo-stage" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "demorepo.stage.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [aws_cloudfront_distribution.demorepo-stage.domain_name]
}