# keep test version and http support for legacy reasons
resource "aws_cloudfront_distribution" "schema-test" {
  origin {
    domain_name = "${aws_s3_bucket.schema-stage.website_endpoint}"
    origin_id   = "schema.stage.datacite.org"

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
    bucket          = "${data.aws_s3_bucket.logs-stage.bucket_domain_name}"
    prefix          = "schema/"
  }

  aliases = ["schema.test.datacite.org"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "schema.stage.datacite.org"

    forwarded_values {
      query_string = false

      cookies {
        forward = "whitelist"
        whitelisted_names = ["_datacite_jwt"]
      }
    }

    viewer_protocol_policy = "allow-all"
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
    Environment = "test"
  }

  viewer_certificate {
    acm_certificate_arn = "${data.aws_acm_certificate.cloudfront-test.arn}"
    ssl_support_method  = "sni-only"
  }
}

resource "aws_route53_record" "schema-test" {
   zone_id = "${data.aws_route53_zone.production.zone_id}"
   name = "schema.test.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${aws_cloudfront_distribution.schema-test.domain_name}"]
}

resource "aws_route53_record" "split-schema-test" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "schema.test.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${aws_cloudfront_distribution.schema-test.domain_name}"]
}
