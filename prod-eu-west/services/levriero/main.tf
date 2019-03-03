resource "aws_ecs_service" "levriero" {
  name = "levriero"
  cluster = "${data.aws_ecs_cluster.default.id}"
  task_definition = "${aws_ecs_task_definition.levriero.arn}"
  desired_count = 3
  iam_role        = "${data.aws_iam_role.ecs_service.arn}"

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.levriero.id}"
    container_name   = "levriero"
    container_port   = "80"
  }
}

resource "aws_cloudwatch_log_group" "levriero" {
  name = "/ecs/levriero"
}

resource "aws_ecs_task_definition" "levriero" {
  family = "levriero"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  container_definitions =  "${data.template_file.levriero_task.rendered}"
}

resource "aws_lb_target_group" "levriero" {
  name     = "levriero"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

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
