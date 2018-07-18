resource "aws_launch_configuration" "mds" {
  name_prefix          = "MDS-"
  image_id             = "${var.mds_ami}"
  security_groups      = ["${data.aws_security_group.datacite-private.id}"]
  instance_type        = "m1.large"
  key_name             = "${var.key_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "mds" {
  name                 = "mds"
  vpc_zone_identifier  = ["${data.aws_subnet.datacite-private.id}"]
  launch_configuration = "${aws_launch_configuration.mds.name}"
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1
  health_check_type    = "ELB"
  health_check_grace_period = 300
  enabled_metrics      = ["GroupInServiceInstances", "GroupTerminatingInstances"]
  target_group_arns    = ["${aws_lb_target_group.mds-legacy.arn}"]

  lifecycle {
    create_before_destroy = true
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

resource "aws_lb_listener_rule" "mds-legacy-legacy" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 13

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.mds-legacy.arn}"
  }

  condition {
    field  = "host-header"
    values = ["mds-legacy.datacite.org"]
  }
}

resource "aws_lb_listener_rule" "mds-legacy" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 14

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.mds-legacy.arn}"
  }

  condition {
    field  = "host-header"
    values = ["mds.datacite.org"]
  }
}

// resource "aws_lb_target_group_attachment" "mds-legacy" {
//   target_group_arn = "${aws_lb_target_group.mds-legacy.arn}"
//   target_id        = "${aws_instance.mds.id}"
// }

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

// resource "aws_route53_record" "internal-main" {
//    zone_id = "${data.aws_route53_zone.internal.zone_id}"
//    name = "main.datacite.org"
//    type = "A"
//    ttl = "300"
//    records = ["${aws_instance.mds.private_ip}"]
// }

// resource "aws_route53_record" "internal-main-ec2" {
//    zone_id = "${data.aws_route53_zone.internal.zone_id}"
//    name = "main.ec2.datacite.org"
//    type = "A"
//    ttl = "300"
//    records = ["${aws_instance.mds.private_ip}"]
// }
