resource "aws_s3_bucket" "pidapalooza" {
    bucket = "pidapalooza.org"
    acl = "public-read"
    policy = "${data.template_file.blog.rendered}"
    website {
        index_document = "index.html"
        error_document = "404.html"
    }
    tags {
        Name = "Pidapalooza"
    }
}

resource "aws_cloudfront_distribution" "pidapalooza" {
  origin {
    domain_name = "${aws_s3_bucket.pidapalooza.website_endpoint}"
    origin_id   = "pidapalooza.org"

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
    bucket          = "${data.aws_s3_bucket.logs.bucket_domain_name}"
    prefix          = "pidapalooza/"
  }

  aliases = ["www.pidapalooza.org", "pidapalooza.org"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "pidapalooza.org"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
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
    Environment = "prod"
  }

  viewer_certificate {
    acm_certificate_arn = "${data.aws_acm_certificate.pidapalooza.arn}"
    ssl_support_method  = "sni-only"
  }
}

resource "aws_route53_record" "www" {
   zone_id = "${data.aws_route53_zone.pidapalooza.zone_id}"
   name = "www.pidapalooza.org"
   type = "A"

   alias {
     name = "${aws_cloudfront_distribution.pidapalooza.domain_name}"
     zone_id = "${var.cloudfront_alias_zone_id}"
     evaluate_target_health = true
   }
}

resource "aws_route53_record" "apex" {
  zone_id = "${data.aws_route53_zone.pidapalooza.zone_id}"
  name = "pidapalooza.org"
  type = "A"

  alias {
    name = "${aws_cloudfront_distribution.pidapalooza.domain_name}"
    zone_id = "${var.cloudfront_alias_zone_id}"
    evaluate_target_health = true
  }
}
