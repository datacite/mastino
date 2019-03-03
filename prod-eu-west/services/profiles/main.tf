resource "aws_ecs_service" "profiles" {
  name = "profiles"
  cluster = "${data.aws_ecs_cluster.default.id}"
  task_definition = "${aws_ecs_task_definition.profiles.arn}"
  desired_count = 2
  iam_role        = "${data.aws_iam_role.ecs_service.arn}"

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.profiles.id}"
    container_name   = "profiles"
    container_port   = "80"
  }
}

resource "aws_cloudwatch_log_group" "profiles" {
  name = "/ecs/profiles"
}

resource "aws_ecs_task_definition" "profiles" {
  family = "profiles"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  container_definitions = "${data.template_file.profiles_task.rendered}"
}

resource "aws_lb_target_group" "profiles" {
  name     = "profiles"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "profiles" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 50

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.profiles.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.profiles.name}"]
  }
}

resource "aws_route53_record" "profiles" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "profiles.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.default.dns_name}"]
}

resource "aws_route53_record" "split-profiles" {
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "profiles.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.default.dns_name}"]
}
