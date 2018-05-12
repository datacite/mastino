resource "aws_lb_target_group" "solr" {
  name     = "solr"
  port     = 40195
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/status"
  }
}

resource "aws_lb_target_group_attachment" "solr" {
  target_group_arn = "${aws_lb_target_group.solr.arn}"
  target_id        = "${element(aws_instance.ecs-solr.*.id, var.search_tags["id"])}"
}

resource "aws_route53_record" "solr" {
   zone_id = "${data.aws_route53_zone.production.zone_id}"
   name = "solr.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.default.dns_name}"]
}

resource "aws_route53_record" "split-solr" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "solr.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.default.dns_name}"]
}

resource "aws_lb_listener_rule" "solr" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 90

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.solr.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.solr.name}"]
  }
}
