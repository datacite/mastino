resource "aws_ecs_service" "profiles-stage" {
  name = "profiles-stage"
  cluster = "${data.aws_ecs_cluster.stage.id}"
  task_definition = "${aws_ecs_task_definition.profiles-stage.arn}"
  desired_count = 1
  iam_role        = "${data.aws_iam_role.ecs_service.arn}"

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.profiles-stage.id}"
    container_name   = "profiles-stage"
    container_port   = "80"
  }
}

resource "aws_ecs_task_definition" "profiles-stage" {
  family = "profiles-stage"
  container_definitions =  "${data.template_file.profiles_task.rendered}"
}

resource "aws_lb_target_group" "profiles-stage" {
  name     = "profiles-stage"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "profiles-stage" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
  priority     = 50

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.profiles-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.profiles-stage.name}"]
  }
}

resource "aws_route53_record" "profiles-stage" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "profiles.test.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.stage.dns_name}"]
}

resource "aws_route53_record" "split-profiles-stage" {
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "profiles.test.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.stage.dns_name}"]
}
