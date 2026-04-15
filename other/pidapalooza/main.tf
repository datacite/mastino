resource "aws_s3_bucket" "pidapalooza" {
  bucket = "pidapalooza.org"
}

resource "aws_s3_bucket_website_configuration" "pidapalooza" {
  bucket = aws_s3_bucket.pidapalooza.id

  redirect_all_requests_to {
    host_name = "pidfest.org"
  }
}

resource "aws_cloudfront_distribution" "pidapalooza" {
  origin {
    domain_name = aws_s3_bucket.pidapalooza.bucket_domain_name
    origin_id   = "pidapalooza.org"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "pidapalooza.org"

    forwarded_values {
      query_string = false
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.cloudfront-pidapalooza.arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.pidapalooza.zone_id
  name    = "pidapalooza.org"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.pidapalooza.domain_name
    zone_id                = aws_cloudfront_distribution.pidapalooza.hosted_zone_id
    evaluate_target_health = false
  }
}
