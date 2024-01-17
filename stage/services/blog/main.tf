# resource "aws_s3_bucket" "blog-stage" {
#     bucket = "blog.stage.datacite.org"
#     acl = "public-read"
#     policy = "${data.template_file.blog-stage.rendered}"
#     website {
#         index_document = "index.html"
#         error_document = "404.html"
#     }
#     tags {
#         Name = "BlogStage"
#     }
# }
# // Remove after blog migration is complete
# resource "aws_cloudfront_distribution" "blog-stage" {
#   origin {
#     domain_name = "${aws_s3_bucket.blog-stage.website_endpoint}"
#     origin_id   = "oldblog.stage.datacite.org"

#     custom_origin_config {
#       origin_protocol_policy = "http-only"
#       http_port = "80"
#       https_port = "443"
#       origin_ssl_protocols = ["TLSv1"]
#     }
#   }

#   enabled             = true
#   is_ipv6_enabled     = true
#   default_root_object = "index.html"

#   logging_config {
#     include_cookies = false
#     bucket          = "${data.aws_s3_bucket.logs-stage.bucket_domain_name}"
#     prefix          = "blog/"
#   }

#   aliases = ["oldblog.stage.datacite.org"]

#   default_cache_behavior {
#     allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = "oldblog.stage.datacite.org"

#     forwarded_values {
#       query_string = false

#       cookies {
#         forward = "whitelist"
#         whitelisted_names = ["_datacite_jwt"]
#       }
#     }

#     viewer_protocol_policy = "redirect-to-https"
#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#   }

#   price_class = "PriceClass_All"

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   tags {
#     Environment = "stage"
#   }

#   viewer_certificate {
#     acm_certificate_arn = "${data.aws_acm_certificate.cloudfront-stage.arn}"
#     ssl_support_method  = "sni-only"
#   }
# }
# // Remove after blog migration is complete
# resource "aws_route53_record" "old-blog-stage" {
#    zone_id = "${data.aws_route53_zone.production.zone_id}"
#    name = "oldblog.stage.datacite.org"
#    type = "CNAME"
#    ttl = "${var.ttl}"
#    records = ["${aws_cloudfront_distribution.blog-stage.domain_name}"]
# }
# // Remove after blog migration is complete
# resource "aws_route53_record" "split-old-blog-stage" {
#    zone_id = "${data.aws_route53_zone.internal.zone_id}"
#    name = "oldblog.stage.datacite.org"
#    type = "CNAME"
#    ttl = "${var.ttl}"
#    records = ["${aws_cloudfront_distribution.blog-stage.domain_name}"]
# }

// Using A record rather than CNAME per https://www.siteground.com/kb/point-website-domain-siteground
resource "aws_route53_record" "blog-stage" {
   zone_id = "${data.aws_route53_zone.production.zone_id}"
   name = "blog.stage.datacite.org"
   type = "A"
   ttl = "${var.ttl}"
   records = ["${var.siteground_ip_stage}"]
}

// Using A record rather than CNAME per https://www.siteground.com/kb/point-website-domain-siteground
resource "aws_route53_record" "blog-stage-wildcard" {
   zone_id = "${data.aws_route53_zone.production.zone_id}"
   name = "*.blog.stage.datacite.org"
   type = "A"
   ttl = "${var.ttl}"
   records = ["${var.siteground_ip_stage}"]
}
