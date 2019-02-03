resource "aws_lb_listener_rule" "redirect_www" {
  listener_arn = "${data.aws_lb_listener.default.arn}"

  action {
    type = "redirect"

    redirect {
      host        = "datacite.org"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }

  condition {
    field  = "host-header"
    values = ["www.datacite.org"]
  }
}

resource "aws_route53_record" "www" {
    zone_id = "${aws_route53_zone.production.zone_id}"
    name = "www.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.default.dns_name}"]
}

resource "aws_route53_record" "split-www" {
    zone_id = "${aws_route53_zone.internal.zone_id}"
    name = "www.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.default.dns_name}"]
}
