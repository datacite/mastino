resource "aws_s3_bucket" "pidservices-stage" {
    bucket = "stage.pidservices.org"
    acl = "public-read"
    policy = "${data.template_file.pidservices-stage.rendered}"

    website {
        index_document = "index.html"
    }

    tags {
        Name = "pidservices-stage"
    }

    versioning {
        enabled = true
    }
}

resource "aws_cloudfront_origin_access_identity" "pidservices_stage_datacite_org" {}

resource "aws_cloudfront_distribution" "pidservices-finder-stage" {
  origin {
    domain_name = "${aws_s3_bucket.pidservices-stage.bucket_domain_name}"
    origin_id   = "pidservices.stage.datacite.org"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.pidservices_stage_datacite_org.cloudfront_access_identity_path}"
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

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "pidservices.stage.datacite.org"

    forwarded_values {
      query_string = false
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
    acm_certificate_arn = "${data.aws_acm_certificate.cloudfront-test.arn}"
    ssl_support_method  = "sni-only"
  }
}


resource "aws_route53_record" "staging" {
    zone_id = "${data.aws_route53_zone.pidservices.zone_id}"
    name = "stage.pidservices.org"
    type = "CNAME"
    ttl = "300"
    records = ["${aws_cloudfront_distribution.pidservices-stage.domain_name}"]
}