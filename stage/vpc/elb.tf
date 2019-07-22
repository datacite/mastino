resource "aws_lb" "stage" {
  name = "lb-stage"
  internal = false
  subnets = ["${data.aws_subnet.datacite-public.id}", "${data.aws_subnet.datacite-public-alt.id}"]
  security_groups = ["${data.aws_security_group.datacite-public.id}"]
  idle_timeout = 200

  enable_deletion_protection = true

  access_logs {
    bucket = "${aws_s3_bucket.logs-stage.bucket}"
    prefix = "lb"
    enabled = true
  }

  tags {
    Environment = "stage"
    Name = "lb-stage"
  }
}

resource "aws_lb" "crosscite-stage" {
  name = "crosscite-stage"
  internal = false
  subnets = ["${data.aws_subnet.datacite-public.id}", "${data.aws_subnet.datacite-public-alt.id}"]
  security_groups = ["${data.aws_security_group.datacite-public.id}"]

  enable_deletion_protection = true

  access_logs {
    bucket = "${aws_s3_bucket.logs-stage.bucket}"
    prefix = "crosscite-stage"
    enabled = true
  }

  tags {
    Environment = "stage"
    Name = "crosscite-stage"
  }
}

resource "aws_s3_bucket" "logs-stage" {
  bucket = "logs.stage.datacite.org"
  acl    = "private"
  policy = "${data.template_file.logs-stage.rendered}"
  tags {
      Name = "lb-stage"
  }
}

resource "aws_lb_listener" "stage" {
  load_balancer_arn = "${aws_lb.stage.id}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${data.aws_acm_certificate.test.arn}"

  default_action {
    target_group_arn = "${data.aws_lb_target_group.api-stage.id}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "crosscite-stage" {
  load_balancer_arn = "${aws_lb.crosscite-stage.id}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${data.aws_acm_certificate.crosscite-test.arn}"

  default_action {
    target_group_arn = "${data.aws_lb_target_group.content-negotiation-stage.id}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "http-stage" {
  load_balancer_arn = "${aws_lb.stage.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

/*

resource "aws_lb_listener_rule" "handle-test" {
  listener_arn = "${aws_lb_listener.test.arn}"
  priority     = 3

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.handle-test.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.handle-test.name}"]
  }
}

resource "aws_lb_listener_rule" "client-api-test-dois" {
  listener_arn = "${aws_lb_listener.test.arn}"
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.client-api-test.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.test-api.name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/dois*"]
  }
}

resource "aws_lb_listener_rule" "client-api-test-clients" {
  listener_arn = "${aws_lb_listener.test.arn}"
  priority     = 21

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.client-api-test.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.test-api.name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/clients*"]
  }
}

resource "aws_lb_listener_rule" "client-api-test-data-centers" {
  listener_arn = "${aws_lb_listener.test.arn}"
  priority     = 22

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.client-api-test.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.test-api.name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/data-centers*"]
  }
}

resource "aws_lb_listener_rule" "client-api-test-providers" {
  listener_arn = "${aws_lb_listener.test.arn}"
  priority     = 23

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.client-api-test.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.test-api.name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/providers*"]
  }
}

resource "aws_lb_listener_rule" "client-api-test-members" {
  listener_arn = "${aws_lb_listener.test.arn}"
  priority     = 24

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.client-api-test.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.test-api.name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/members*"]
  }
}

resource "aws_lb_listener_rule" "client-api-test-prefixes" {
  listener_arn = "${aws_lb_listener.test.arn}"
  priority     = 25

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.client-api-test.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.test-api.name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/prefixes*"]
  }
}

resource "aws_lb_listener_rule" "client-api-test-provider-prefixes" {
  listener_arn = "${aws_lb_listener.test.arn}"
  priority     = 26

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.client-api-test.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.test-api.name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/provider-prefixes*"]
  }
}

resource "aws_lb_listener_rule" "client-api-test-client-prefixes" {
  listener_arn = "${aws_lb_listener.test.arn}"
  priority     = 27

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.client-api-test.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.test-api.name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/client-prefixes*"]
  }
}

resource "aws_lb_listener_rule" "client-api-test-repositories" {
  listener_arn = "${aws_lb_listener.test.arn}"
  priority     = 28

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.client-api-test.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.test-api.name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/repositories*"]
  }
}

resource "aws_lb_listener_rule" "client-api-test-status" {
  listener_arn = "${aws_lb_listener.test.arn}"
  priority     = 29

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.client-api-test.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.test-api.name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/status"]
  }
}

resource "aws_lb_listener_rule" "client-api-test-heartbeat" {
  listener_arn = "${aws_lb_listener.test.arn}"
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.client-api-test.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.test-api.name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/hearbeat"]
  }
}

resource "aws_lb_listener_rule" "data-test" {
  listener_arn = "${aws_lb_listener.test.arn}"
  priority     = 60

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.data-test.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.data-test.name}"]
  }
}

resource "aws_lb_listener_rule" "elastic-api-test" {
  listener_arn = "${aws_lb_listener.test.arn}"
  priority     = 70

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.elastic-api-test.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.elastic-api-test.name}"]
  }
}

resource "aws_lb_listener_rule" "solr-test-api" {
  listener_arn = "${aws_lb_listener.test.arn}"
  priority     = 80

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.solr-test.arn}"
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

resource "aws_lb_listener_rule" "solr-test-list" {
  listener_arn = "${aws_lb_listener.test.arn}"
  priority     = 81

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.solr-test.arn}"
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

resource "aws_lb_listener_rule" "solr-test-ui" {
  listener_arn = "${aws_lb_listener.test.arn}"
  priority     = 82

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.solr-test.arn}"
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

resource "aws_lb_listener_rule" "solr-test-resources" {
  listener_arn = "${aws_lb_listener.test.arn}"
  priority     = 83

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.solr-test.arn}"
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

resource "aws_lb_listener_rule" "search-test" {
  listener_arn = "${aws_lb_listener.test.arn}"
  priority     = 89

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.search-test.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.search-test.name}"]
  }
}

resource "aws_lb_listener_rule" "solr-test" {
  listener_arn = "${aws_lb_listener.test.arn}"
  priority     = 90

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.solr-test.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.solr-test.name}"]
  }
}

resource "aws_lb_listener_rule" "oai-test" {
  listener_arn = "${aws_lb_listener.test.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.oai-test.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.oai-test.name}"]
  }
}

resource "aws_lb_listener_rule" "citation-test" {
  listener_arn = "${aws_lb_listener.test.arn}"
  priority     = 110

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.citation-test.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.citation-test.name}"]
  }
} */
