resource "aws_ecs_service" "eventdata" {
  name = "eventdata"
  cluster = "${data.aws_ecs_cluster.default.id}"
  task_definition = "${aws_ecs_task_definition.eventdata.arn}"
  desired_count = 1
  iam_role        = "${data.aws_iam_role.ecs_service.arn}"

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.eventdata.id}"
    container_name   = "eventdata"
    container_port   = "80"
  }
}

resource "aws_ecs_task_definition" "eventdata" {
  family = "eventdata"
  container_definitions =  "${data.template_file.eventdata_task.rendered}"
}

resource "aws_lb_target_group" "eventdata" {
  name     = "eventdata"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener_rule" "eventdata" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 31

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.eventdata.arn}"
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
