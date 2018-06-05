resource "aws_lb_target_group" "mds" {
  name     = "mds"
  vpc_id   = "${var.vpc_id}"
  port     = 80
  protocol = "HTTP"

  health_check {
    path = "/"
  }
}

resource "aws_lb_target_group_attachment" "mds" {
  target_group_arn = "${aws_lb_target_group.mds.arn}"
  target_id        = "${data.aws_instance.main.id}"
}

resource "aws_lb_listener_rule" "mds" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.mds.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.mds.name}"]
  }
}

resource "aws_route53_record" "mds" {
   zone_id = "${data.aws_route53_zone.production.zone_id}"
   name = "mds.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.default.dns_name}"]
}

resource "aws_route53_record" "internal-mds-split" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "mds.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.default.dns_name}"]
}

resource "aws_route53_record" "internal-main" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "main.datacite.org"
   type = "A"
   ttl = "300"
   records = ["${var.main_private_ip}"]
}

resource "aws_route53_record" "internal-main-ec2" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "main.ec2.datacite.org"
   type = "A"
   ttl = "300"
   records = ["${var.main_private_ip}"]
}
