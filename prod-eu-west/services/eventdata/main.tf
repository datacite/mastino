resource "aws_ecs_service" "eventdata" {
  name = "eventdata"
  cluster = "${data.aws_ecs_cluster.default.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.eventdata.arn}"
  desired_count = 3

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.eventdata.id}"
    container_name   = "eventdata"
    container_port   = "80"
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.eventdata.arn}"
  }

  depends_on = [
    "data.aws_lb_listener.default",
  ]
}

resource "aws_cloudwatch_log_group" "eventdata" {
  name = "/ecs/eventdata"
}

resource "aws_ecs_task_definition" "eventdata" {
  family = "eventdata"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "1024"
  memory = "2048"
  container_definitions =  "${data.template_file.eventdata_task.rendered}"
}

resource "aws_lb_target_group" "eventdata" {
  name     = "eventdata"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "eventdata" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 39

  // action {
  //   type             = "forward"
  //   target_group_arn = "${aws_lb_target_group.eventdata.arn}"
  // }

  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "The server is currently unable to handle the GraphQL API call due to a temporary overloading or maintenance of the server."
      status_code = "503"
    }
  }

  condition {
    field  = "host-header"
    values = ["api.datacite.org"]
  }

  condition {
    field  = "path-pattern"
    values = ["/events*"]
  }
}

resource "aws_service_discovery_service" "eventdata" {
  name = "eventdata"

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
