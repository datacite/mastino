resource "aws_lb_target_group" "mds-stage" {
  name     = "mds-stage"
  vpc_id   = "${var.vpc_id}"
  port     = 8080
  protocol = "HTTP"
}

/* resource "aws_lb_listener_rule" "mds-stage" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.mds-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.mds-stage.name}"]
  }
} */

resource "aws_lb_target_group_attachment" "mds-stage" {
  target_group_arn = "${aws_lb_target_group.mds-stage.arn}"
  target_id        = "${data.aws_instance.compose-stage.id}"
}

resource "aws_route53_record" "mds-stage" {
   zone_id = "${data.aws_route53_zone.production.zone_id}"
   name = "mds.test.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.stage.dns_name}"]
}

resource "aws_route53_record" "split-mds-stage" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "mds.test.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.stage.dns_name}"]
}
