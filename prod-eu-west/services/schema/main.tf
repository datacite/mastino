resource "aws_s3_bucket" "schema" {
    bucket = "schema.datacite.org"
    acl = "public-read"
    policy = "${data.template_file.schema.rendered}"
    website {
        index_document = "index.html"
        error_document = "404.html"
    }
    tags {
        Name = "Schema"
    }
}

resource "aws_cloudfront_distribution" "schema" {
  origin {
    domain_name = "${aws_s3_bucket.schema.website_endpoint}"
    origin_id   = "schema.datacite.org"

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
    prefix          = "schema/"
  }

  aliases = ["schema.datacite.org"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "schema.datacite.org"

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
    Environment = "prod"
  }

  viewer_certificate {
    acm_certificate_arn = "${data.aws_acm_certificate.cloudfront.arn}"
    ssl_support_method  = "sni-only"
  }
}

resource "aws_route53_record" "schema" {
   zone_id = "${data.aws_route53_zone.production.zone_id}"
   name = "schema.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${aws_cloudfront_distribution.schema.domain_name}"]
}

resource "aws_route53_record" "split-schema" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "schema.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${aws_cloudfront_distribution.schema.domain_name}"]
}
