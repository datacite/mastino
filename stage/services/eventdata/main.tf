resource "aws_ecs_service" "eventdata-stage" {
  name = "eventdata-stage"
  cluster = "${data.aws_ecs_cluster.stage.id}"
  task_definition = "${aws_ecs_task_definition.eventdata.arn}"
  desired_count = 1
  iam_role        = "${data.aws_iam_role.ecs_service.arn}"

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.eventdata-stage.id}"
    container_name   = "eventdata-stage"
    container_port   = "80"
  }
}

resource "aws_ecs_task_definition" "eventdata" {
  family = "eventdata-stage"
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
  priority     = 33

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.eventdata-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.eventdata-stage.name}"]
  }
}

resource "aws_route53_record" "eventdata-stage" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "eventdata.test.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.stage.dns_name}"]
}

resource "aws_route53_record" "split-eventdata-stage" {
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "eventdata.test.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.stage.dns_name}"]
}
