resource "aws_s3_bucket" "pidapalooza" {
  bucket = "pidapalooza.org"
}

resource "aws_s3_bucket_website_configuration" "pidapalooza" {
  bucket = aws_s3_bucket.pidapalooza.id

  redirect_all_requests_to = {
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
