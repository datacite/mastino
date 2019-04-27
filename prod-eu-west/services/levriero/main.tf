resource "aws_ecs_service" "levriero" {
  name = "levriero"
  cluster = "${data.aws_ecs_cluster.default.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.levriero.arn}"
  desired_count = 4

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.levriero.id}"
    container_name   = "levriero"
    container_port   = "80"
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.levriero.arn}"
  }

  depends_on = [
    "data.aws_lb_listener.default",
  ]
}

resource "aws_cloudwatch_log_group" "levriero" {
  name = "/ecs/levriero"
}

resource "aws_ecs_task_definition" "levriero" {
  family = "levriero"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "1024"
  memory = "2048"
  container_definitions =  "${data.template_file.levriero_task.rendered}"
}

resource "aws_lb_target_group" "levriero" {
  name     = "levriero"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "levriero" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 17

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.levriero.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.api_dns_name}"]
  }

  condition {
    field  = "path-pattern"
    values = ["/agents*"]
  }
}

resource "aws_service_discovery_service" "levriero" {
  name = "levriero"

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
