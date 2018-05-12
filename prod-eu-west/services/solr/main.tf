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
  target_id        = "${data.terraform_remote_state.vpc.search_tags["id"] == "1" ? data.aws_instance.ecs-solr-1.id : data.aws_instance.ecs-solr-2.id}"
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

resource "aws_lb_listener_rule" "solr-api" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 80

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.solr.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.aws_route53_record_search_name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/api*"]
  }
}

resource "aws_lb_listener_rule" "solr-list" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 81

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.solr.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.aws_route53_record_search_name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/list*"]
  }
}

resource "aws_lb_listener_rule" "solr-ui" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 82

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.solr.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.aws_route53_record_search_name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/ui*"]
  }
}

resource "aws_lb_listener_rule" "solr-resources" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 83

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.solr.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.aws_route53_record_search_name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/resources*"]
  }
}

resource "aws_lb_listener_rule" "search" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 89

  action {
    type             = "forward"
    target_group_arn = "${data.aws_lb_target_group.search.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.aws_route53_record_search_name}"]
  }
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
