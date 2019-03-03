resource "aws_ecs_service" "eventdata-stage" {
  name = "eventdata-stage"
  cluster = "${data.aws_ecs_cluster.stage.id}"
  task_definition = "${aws_ecs_task_definition.eventdata-stage.arn}"
  desired_count = 1
  iam_role        = "${data.aws_iam_role.ecs_service.arn}"

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.eventdata-stage.id}"
    container_name   = "eventdata-stage"
    container_port   = "80"
  }
}

resource "aws_cloudwatch_log_group" "eventdata-stage" {
  name = "/ecs/eventdata-stage"
}

resource "aws_ecs_task_definition" "eventdata-stage" {
  family = "eventdata-stage"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  container_definitions =  "${data.template_file.eventdata_task.rendered}"
}

resource "aws_lb_target_group" "eventdata-stage" {
  name     = "eventdata-stage"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "eventdata-stage" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
  priority     = 31

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.eventdata-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["api.test.datacite.org"]
  }

  condition {
    field  = "path-pattern"
    values = ["/events*"]
  }
}
