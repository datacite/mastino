resource "aws_ecs_service" "metrics-api-stage" {
  name            = "metrics-api-stage"
  cluster         = "${data.aws_ecs_cluster.stage.id}"
  task_definition = "${aws_ecs_task_definition.metrics-api-stage.arn}"
  desired_count   = 1
  iam_role        = "${data.aws_iam_role.ecs_service.arn}"

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.metrics-api-stage.id}"
    container_name   = "metrics-api-stage"
    container_port   = "80"
  }
}

resource "aws_lb_target_group" "metrics-api-stage" {
  name     = "metrics-api-stage"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_lb_listener_rule" "metrics-api-stage" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
  priority     = 116

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.metrics-api-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["api.test.datacite.org"]
  }

  condition {
    field  = "path-pattern"
    values = ["/reports*"]
  }
}

resource "aws_ecs_task_definition" "metrics-api-stage" {
  family = "metrics-api-stage"
  container_definitions =  "${data.template_file.metrics-api_task.rendered}"
}

resource "aws_route53_record" "metrics-api-stage" {
  zone_id = "${data.aws_route53_zone.production.zone_id}"
  name = "metrics.test.datacite.org"
  type = "CNAME"
  ttl = "${var.ttl}"
  records = ["${data.aws_lb.stage.dns_name}"]
}

resource "aws_route53_record" "split-metrics-api-stage" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name = "metrics.test.datacite.org"
  type = "CNAME"
  ttl = "${var.ttl}"
  records = ["${data.aws_lb.stage.dns_name}"]
}