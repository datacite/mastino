resource "aws_ecs_service" "cheetoh" {
  name = "cheetoh"
  cluster = "${data.aws_ecs_cluster.default.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.cheetoh.arn}"
  desired_count = 2

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.cheetoh.id}"
    container_name   = "cheetoh"
    container_port   = "80"
  }

  depends_on = [
    "data.aws_lb_listener.default",
  ]
}

resource "aws_cloudwatch_log_group" "cheetoh" {
  name = "/ecs/cheetoh"
}

resource "aws_ecs_task_definition" "cheetoh" {
  family = "cheetoh"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "512"

  container_definitions =  "${data.template_file.cheetoh_task.rendered}"
}

resource "aws_lb_target_group" "cheetoh" {
  name     = "cheetoh"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "cheetoh" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.cheetoh.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.cheetoh.name}"]
  }
}

resource "aws_route53_record" "cheetoh" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "ez.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.default.dns_name}"]
}

resource "aws_route53_record" "split-cheetoh" {
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "ez.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.default.dns_name}"]
}
