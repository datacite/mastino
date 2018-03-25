resource "aws_lb_target_group" "handle-stage" {
  name     = "handle-stage"
  vpc_id   = "${var.vpc_id}"
  port     = 8000
  protocol = "HTTP"

  health_check {
    path = "/"
  }
}

resource "aws_lb_target_group_attachment" "handle-stage" {
  target_group_arn = "${aws_lb_target_group.handle-stage.arn}"
  target_id        = "${data.aws_instance.compose-stage.id}"
}

resource "aws_route53_record" "handle-stage" {
   zone_id = "${aws_route53_zone.production.zone_id}"
   name = "handle.test.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.stage.dns_name}"]
}

resource "aws_route53_record" "split-handle-stage" {
   zone_id = "${aws_route53_zone.internal.zone_id}"
   name = "handle.test.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.stage.dns_name}"]
}
