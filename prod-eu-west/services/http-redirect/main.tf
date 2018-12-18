resource "aws_ecs_service" "http-redirect" {
  name = "http-redirect"
  cluster = "${data.aws_ecs_cluster.default.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.http-redirect.arn}"
  desired_count = 2

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.http-redirect.id}"
    container_name   = "http-redirect"
    container_port   = "80"
  }

  depends_on = [
    "data.aws_lb_listener.default-http"
  ]
}

resource "aws_lb_target_group" "http-redirect" {
  name     = "http-redirect"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_cloudwatch_log_group" "http-redirect" {
  name = "/ecs/http-redirect"
}

resource "aws_ecs_task_definition" "http-redirect" {
  family = "http-redirect"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}",
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "1024"

  container_definitions =  "${data.template_file.http-redirect_task.rendered}"
}
