resource "aws_s3_bucket" "repository-finder-stage" {
    bucket = "repositoryfinder.stage.datacite.org"
    acl = "public-read"
    policy = "${data.template_file.repository-finder-stage.rendered}"
    website {
        index_document = "index.html"
    }
    tags {
        Name = "repository-finder-stage"
    }
    versioning {
        enabled = true
    }
}

resource "aws_cloudfront_origin_access_identity" "repository-finder_stage_datacite_org" {}

resource "aws_cloudfront_distribution" "repository-finder-stage" {
  origin {
    domain_name = "${aws_s3_bucket.repository-finder-stage.bucket_domain_name}"
    origin_id   = "repositoryfinder.stage.datacite.org"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.repository-finder_stage_datacite_org.cloudfront_access_identity_path}"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = "${data.aws_s3_bucket.logs-stage.bucket_domain_name}"
    prefix          = "repository-finder/"
  }

  aliases = ["repositoryfinder.stage.datacite.org"]

  custom_error_response {
    error_code            = "404"
    error_caching_min_ttl = "5"
    response_code         = "200"
    response_page_path    = "/index.html"
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "repositoryfinder.stage.datacite.org"

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

  tags {
    Environment = "stage"
  }

  viewer_certificate {
    acm_certificate_arn = "${data.aws_acm_certificate.cloudfront-stage.arn}"
    ssl_support_method  = "sni-only"
  }
}

resource "aws_route53_record" "repository-finder-stage" {
  zone_id = "${data.aws_route53_zone.production.zone_id}"
  name = "repositoryfinder.stage.datacite.org"
  type = "CNAME"
  ttl = "${var.ttl}"
  records = ["${aws_cloudfront_distribution.repository-finder-stage.domain_name}"]
}

resource "aws_route53_record" "split-repository-finder-stage" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name = "repositoryfinder.stage.datacite.org"
  type = "CNAME"
  ttl = "${var.ttl}"
  records = ["${aws_cloudfront_distribution.repository-finder-stage.domain_name}"]
}
