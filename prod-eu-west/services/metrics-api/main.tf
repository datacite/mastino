resource "aws_ecs_service" "metrics-api" {
  name            = "metrics-api"
  cluster         = "${data.aws_ecs_cluster.default.id}"
  task_definition = "${aws_ecs_task_definition.metrics-api.arn}"
  desired_count   = 1
  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = "${aws_lb_target_group.metrics-api.id}"
    container_name   = "metrics-api"
    container_port   = "80"
  }

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

   service_registries {
    registry_arn = "${aws_service_discovery_service.metrics-api.arn}"
  }

    depends_on = [
    "data.aws_lb_listener.default",
  ]
  
}

resource "aws_lb_target_group" "metrics-api" {
  name     = "metrics-api"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "ip"


  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "metrics-api" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 19

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
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "1024"
  memory = "2048"
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

resource "aws_service_discovery_service" "metrics-api" {
  name = "metrics-api"

    health_check_custom_config {
    failure_threshold = 3
  }

    dns_config {
    namespace_id = "${var.namespace_id}"

      dns_records {
      ttl = 300
      type = "A"
    }
  }
}