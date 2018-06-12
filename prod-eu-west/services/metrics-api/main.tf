resource "aws_ecs_service" "metrics-api" {
  name            = "metrics-api"
  cluster         = "${data.aws_ecs_cluster.default.id}"
  task_definition = "${aws_ecs_task_definition.metrics-api.arn}"
  desired_count   = 1
  iam_role        = "${data.aws_iam_role.ecs_service.arn}"

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.metrics-api.id}"
    container_name   = "metrics-api"
    container_port   = "80"
  }
}

resource "aws_lb_target_group" "metrics-api" {
  name     = "metrics-api"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "metrics-api" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 27

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.metrics-api.arn}"
  }

  condition {
    field  = "host-header"
    values = ["api.datacite.org"]
  }

  condition {
    field  = "path-pattern"
    values = ["/reports*"]
  }
}

resource "aws_cloudwatch_log_group" "metrics-api" {
  name = "/ecs/metrics-api"
}

resource "aws_ecs_task_definition" "metrics-api" {
  family = "metrics-api"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  container_definitions =  "${data.template_file.metrics-api_task.rendered}"
}

resource "aws_route53_record" "metrics-api" {
  zone_id = "${data.aws_route53_zone.production.zone_id}"
  name = "metrics.datacite.org"
  type = "CNAME"
  ttl = "${var.ttl}"
  records = ["${data.aws_lb.default.dns_name}"]
}

resource "aws_route53_record" "split-metrics-api" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name = "metrics.datacite.org"
  type = "CNAME"
  ttl = "${var.ttl}"
  records = ["${data.aws_lb.default.dns_name}"]
}