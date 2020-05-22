resource "aws_ecs_service" "levriero-stage" {
  name = "levriero-stage"
  cluster = "${data.aws_ecs_cluster.stage.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.levriero-stage.arn}"
  desired_count = 1

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.levriero-stage.id}"
    container_name   = "levriero-stage"
    container_port   = "80"
  }

  // service_registries {
  //   registry_arn = "${aws_service_discovery_service.levriero-stage.arn}"
  // }

  depends_on = [
    "data.aws_lb_listener.stage",
  ]
}

resource "aws_cloudwatch_log_group" "levriero-stage" {
  name = "/ecs/levriero-stage"
}

resource "aws_ecs_task_definition" "levriero-stage" {
  family = "levriero-stage"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "2048"
  container_definitions =  "${data.template_file.levriero_task.rendered}"
}

resource "aws_lb_target_group" "levriero-stage" {
  name     = "levriero-stage"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "levriero-stage" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
  priority     = 18

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.levriero-stage.arn}"
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

resource "aws_service_discovery_service" "levriero-stage" {
  name = "levriero.stage"

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
