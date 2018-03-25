resource "aws_lb_target_group" "mds-test" {
  name     = "mds-test"
  vpc_id   = "${var.vpc_id}"
  port     = 8080
  protocol = "HTTP"
}

resource "aws_lb_listener_rule" "mds-test" {
  listener_arn = "${data.aws_lb_listener.test.arn}"
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.mds-test.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.mds-test.name}"]
  }
}

resource "aws_lb_target_group_attachment" "mds-test" {
  target_group_arn = "${aws_lb_target_group.mds-test.arn}"
  target_id        = "${data.aws_instance.compose-test.id}"
}

resource "aws_route53_record" "mds-test" {
   zone_id = "${data.aws_route53_zone.production.zone_id}"
   name = "mds.test.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.test.dns_name}"]
}

resource "aws_route53_record" "split-mds-test" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "mds.test.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.test.dns_name}"]
}
