resource "aws_ecs_service" "handle-stage" {
  name            = "handle-stage"
  cluster         = "${data.aws_ecs_cluster.stage.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.handle-stage.arn}"
  desired_count   = 1

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
}

resource "aws_cloudwatch_log_group" "handle-stage" {
  name = "/ecs/handle-stage"
}

resource "aws_ecs_task_definition" "handle-stage" {
  family                = "pidcheck-stage"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  container_definitions = "${data.template_file.handle_task.rendered}"
  requires_compatibilities = ["FARGATE"]
}

resource "aws_lb_target_group" "handle-stage" {
  name     = "handle-stage"
  vpc_id   = "${var.vpc_id}"
  port     = 80
  protocol = "HTTP"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener_rule" "handle-stage" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
  priority     = 3

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.handle-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.handle-stage.name}"]
  }
}

resource "aws_route53_record" "handle-stage" {
   zone_id = "${data.aws_route53_zone.production.zone_id}"
   name = "handle.test.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.stage.dns_name}"]
}

resource "aws_route53_record" "split-handle-stage" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "handle.test.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.stage.dns_name}"]
}
