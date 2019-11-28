resource "aws_ecs_service" "federation" {
  name = "federation"
  cluster = "${data.aws_ecs_cluster.default.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.federation.arn}"
  desired_count = 2

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.federation.id}"
    container_name   = "federation"
    container_port   = "80"
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.federation.arn}"
  }

  depends_on = [
    "data.aws_lb_listener.default",
  ]
}

resource "aws_cloudwatch_log_group" "federation" {
  name = "/ecs/federation"
}

resource "aws_ecs_task_definition" "federation" {
  family = "federation"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "512"

  container_definitions =  "${data.template_file.federation_task.rendered}"
}

resource "aws_lb_target_group" "federation" {
  name     = "federation"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "federation" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 38

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.federation.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.api_dns_name}"]
  }

  condition {
    field  = "path-pattern"
    values = ["/graphql"]
  }
}

resource "aws_service_discovery_service" "federation" {
  name = "federation"

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
