
resource "aws_route53_record" "test" {
   zone_id = data.aws_route53_zone.production.zone_id
   name = "test.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [data.aws_lb.default.dns_name]
}

resource "aws_route53_record" "split-test" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "test.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [data.aws_lb.default.dns_name]
}

resource "aws_lb_listener_rule" "test-support-redirect" {
  listener_arn = data.aws_lb_listener.default.arn

  action {
    type = "redirect"

    redirect {
      host = "support.datacite.org"
      path = "/docs/testing-guide/"
      query = ""
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["test.datacite.org"]
    }
  }
}
