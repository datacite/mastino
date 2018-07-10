resource "aws_ecs_service" "re3data" {
  name = "re3data"
  cluster = "${data.aws_ecs_cluster.default.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.re3data.arn}"
  desired_count = 1

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.re3data.id}"
    container_name   = "re3data"
    container_port   = "80"
  }
}

resource "aws_cloudwatch_log_group" "re3data" {
  name = "/ecs/re3data"
}

resource "aws_ecs_task_definition" "re3data" {
  family = "re3data"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "2048"

  container_definitions =  "${data.template_file.re3data_task.rendered}"
}

resource "aws_lb_target_group" "re3data" {
  name     = "re3data"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener_rule" "re3data" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 34

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.re3data.arn}"
  }

  condition {
    field  = "host-header"
    values = ["api.datacite.org"]
  }

  condition {
    field  = "path-pattern"
    values = ["/repositories*"]
  }
}