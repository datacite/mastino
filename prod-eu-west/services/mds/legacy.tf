resource "aws_instance" "mds" {
  ami = "${var.mds_ami}"
  instance_type = "m1.large"
  vpc_security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
  subnet_id = "${data.aws_subnet.datacite-private.id}"
  key_name = "${var.key_name}"
  tags {
      Name = "MDS"
  }
  lifecycle {
      create_before_destroy = "true"
  }
}

resource "aws_lb_target_group" "mds-legacy" {
  name     = "mds-legacy"
  vpc_id   = "${var.vpc_id}"
  port     = 80
  protocol = "HTTP"

  health_check {
    path = "/"
  }
}

resource "aws_lb_target_group_attachment" "mds-legacy" {
  target_group_arn = "${aws_lb_target_group.mds-legacy.arn}"
  target_id        = "${aws_instance.mds.id}"
}

resource "aws_lb_listener_rule" "mds-legacy" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 12

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.mds-legacy.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.mds-legacy-rr.name}"]
  }
}

resource "aws_lb_listener_rule" "mds-legacy-legacy" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 13

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.mds-legacy.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.mds-legacy.name}"]
  }
}

resource "aws_route53_record" "mds-legacy" {
   zone_id = "${data.aws_route53_zone.production.zone_id}"
   name = "mds-legacy.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.default.dns_name}"]
}

resource "aws_route53_record" "split-mds-legacy" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "mds-legacy.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.default.dns_name}"]
}

resource "aws_route53_record" "internal-main" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "main.datacite.org"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.mds.private_ip}"]
}

resource "aws_route53_record" "internal-main-ec2" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "main.ec2.datacite.org"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.mds.private_ip}"]
}
