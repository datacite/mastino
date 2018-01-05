/* resource "aws_lb_target_group" "solr-stage" {
  name     = "solr-stage"
  port     = 40195
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/status"
  }
}

resource "aws_lb_target_group_attachment" "solr-stage" {
  target_group_arn = "${aws_lb_target_group.solr-stage.arn}"
  target_id        = "${data.aws_instance.ecs-stage.id}"
}

resource "aws_route53_record" "solr-stage" {
   zone_id = "${data.aws_route53_zone.production.zone_id}"
   name = "solr.test.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.test.dns_name}"]
}

resource "aws_route53_record" "split-solr-stage" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "solr.test.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.stage.dns_name}"]
}

resource "aws_lb_listener_rule" "solr-test-api" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
  priority     = 80

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.solr-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.search-test.name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/api*"]
  }
}

resource "aws_lb_listener_rule" "solr-stage-list" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
  priority     = 81

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.solr-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.search-test.name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/list*"]
  }
}

resource "aws_lb_listener_rule" "solr-stage-ui" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
  priority     = 82

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.solr-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.search-test.name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/ui*"]
  }
}

resource "aws_lb_listener_rule" "solr-stage-resources" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
  priority     = 83

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.solr-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.search-test.name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/resources*"]
  }
}

resource "aws_lb_listener_rule" "solr-stage" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
  priority     = 90

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.solr-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.solr-test.name}"]
  }
} */
