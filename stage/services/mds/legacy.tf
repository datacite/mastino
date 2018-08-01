resource "aws_lb_target_group" "mds-legacy-stage" {
  name     = "mds-legacy-stage"
  vpc_id   = "${var.vpc_id}"
  port     = 8080
  protocol = "HTTP"

  health_check {
    path = "/"
  }
}

// resource "aws_lb_listener_rule" "mds-stage" {
//   listener_arn = "${data.aws_lb_listener.stage.arn}"
//   priority     = 8

//   action {
//     type             = "forward"
//     target_group_arn = "${aws_lb_target_group.mds-legacy-stage.arn}"
//   }

//   condition {
//     field  = "host-header"
//     values = ["${aws_route53_record.mds-stage.name}"]
//   }
// }

resource "aws_lb_listener_rule" "mds-legacy-stage" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
  priority     = 4

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.mds-legacy-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.mds-legacy-stage.name}"]
  }
}

resource "aws_lb_target_group_attachment" "mds-legacy-stage" {
  target_group_arn = "${aws_lb_target_group.mds-legacy-stage.arn}"
  target_id        = "${data.aws_instance.compose-stage.id}"
}

resource "aws_route53_record" "mds-legacy-stage" {
   zone_id = "${data.aws_route53_zone.production.zone_id}"
   name = "mds-legacy.test.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.stage.dns_name}"]
}

resource "aws_route53_record" "split-mds-legacy-stage" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "mds-legacy.test.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.stage.dns_name}"]
}