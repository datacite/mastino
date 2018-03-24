resource "aws_lb_target_group" "mds-test" {
  name     = "mds-test"
  vpc_id   = "${var.vpc_id}"
  port     = 8080
  protocol = "HTTP"
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
   records = ["${aws_lb.test.dns_name}"]
}

resource "aws_route53_record" "split-mds-test" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "mds.test.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.test.dns_name}"]
}
