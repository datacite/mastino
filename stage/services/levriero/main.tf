resource "aws_ecs_service" "levriero-stage" {
  name = "levriero-stage"
  cluster = "${data.aws_ecs_cluster.stage.id}"
  task_definition = "${aws_ecs_task_definition.levriero-stage.arn}"
  desired_count = 1
  iam_role        = "${data.aws_iam_role.ecs_service.arn}"

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.levriero-stage.id}"
    container_name   = "levriero-stage"
    container_port   = "80"
  }
}

resource "aws_cloudwatch_log_group" "levriero-stage" {
  name = "/ecs/levriero-stage"
}

resource "aws_ecs_task_definition" "levriero-stage" {
  family = "levriero-stage"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  container_definitions =  "${data.template_file.levriero_task.rendered}"
}

resource "aws_lb_target_group" "levriero-stage" {
  name     = "levriero-stage"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

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
