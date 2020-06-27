resource "aws_s3_bucket" "pidnotebooks-stage" {
    bucket = "stage.pidnotebooks.org"
    acl = "public-read"
    policy = templatefile("s3_cloudfront.json", {
      bucket_name = "stage.pidnotebooks.org"
    })

    website {
        index_document = "index.html"
    }

    tags = {
        Name = "pidnotebooks-stage"
    }

    versioning {
        enabled = true
    }
}

resource "aws_cloudfront_origin_access_identity" "stage_pidnotebooks_org" {}

resource "aws_cloudfront_distribution" "pidnotebooks-stage" {
  origin {
    domain_name = aws_s3_bucket.pidnotebooks-stage.bucket_domain_name
    origin_id   = "stage.pidnotebooks.org"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.stage_pidnotebooks_org.cloudfront_access_identity_path
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

  aliases = ["stage.pidnotebooks.org"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "stage.pidnotebooks.org"

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
    Environment = "stage"
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.cloudfront-pidnotebooks.arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_route53_record" "staging" {
    zone_id = data.aws_route53_zone.pidnotebooks.zone_id
    name = "stage.pidnotebooks.org"
    type = "CNAME"
    ttl = "300"
    records = [ aws_cloudfront_distribution.pidnotebooks-stage.domain_name ]
}

resource "aws_route53_zone" "pidnotebooks" {
  name = "pidnotebooks.org"

  tags {
    Environment = "production"
  }
}

resource "aws_route53_record" "pidnotebooks-ns" {
  zone_id = "${aws_route53_zone.pidnotebooks.zone_id}"
  name = "${aws_route53_zone.pidnotebooks.name}"
  type = "NS"
  ttl = "300"
    records = [
    "${aws_route53_zone.pidnotebooks.name_servers.0}",
    "${aws_route53_zone.pidnotebooks.name_servers.1}",
    "${aws_route53_zone.pidnotebooks.name_servers.2}",
    "${aws_route53_zone.pidnotebooks.name_servers.3}"
  ]
}

resource "aws_route53_record" "mx-pidnotebooks" {
  zone_id = "${aws_route53_zone.pidnotebooks.zone_id}"
  name = "${aws_route53_zone.pidnotebooks.name}"
  type = "MX"
  ttl = "300"
  records = [
    "1 aspmx.l.google.com",
    "5 alt1.aspmx.l.google.com",
    "5 alt2.aspmx.l.google.com",
    "10 aspmx2.googlemail.com",
    "10 aspmx3.googlemail.com"
  ]
}
