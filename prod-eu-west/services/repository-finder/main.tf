resource "aws_lb_listener_rule" "repository-finder-redirect" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 88
  
  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      host = "commons.datacite.org"
      path = "/repositories"
      query = ""
    }
  }
  condition {
    host_header {
      values = ["${aws_route53_record.repository-finder.name}"]
    }
  }
}

resource "aws_route53_record" "repository-finder" {
  zone_id = "${data.aws_route53_zone.production.zone_id}"
  name = "repositoryfinder.datacite.org"
  type = "CNAME"
  ttl = "${var.ttl}"
  records = ["${data.aws_lb.default.dns_name}"] 
}

resource "aws_route53_record" "split-repository-finder" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name = "repositoryfinder.datacite.org"
  type = "CNAME"
  ttl = "${var.ttl}"
  records = ["${data.aws_lb.default.dns_name}"] 
}
