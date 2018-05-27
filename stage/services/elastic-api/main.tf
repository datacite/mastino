resource "aws_ecs_service" "elastic-api-stage" {
  name = "elastic-api-stage"
  cluster = "${data.aws_ecs_cluster.stage.id}"
  task_definition = "${aws_ecs_task_definition.elastic-api-stage.arn}"
  desired_count = 1
  iam_role        = "${data.aws_iam_role.ecs_service.arn}"

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.elastic-api-stage.id}"
    container_name   = "elastic-api-stage"
    container_port   = "80"
  }

  depends_on = [
    "aws_iam_role_policy.ecs_service",
    "aws_lb_listener.default",
  ]
}

resource "aws_cloudwatch_log_group" "elastic-api-stage" {
  name = "/ecs/elastic-api-stage"
}

resource "aws_ecs_task_definition" "elastic-api-stage" {
  family = "elastic-api-stage"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  container_definitions =  "${data.template_file.elastic-api-stage_task.rendered}"
}

resource "aws_lb_target_group" "elastic-api-stage" {
  name     = "elastic-api-stage"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener_rule" "elastic-api-stage" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.elastic-api-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.elastic-api-stage.name}"]
  }
}

