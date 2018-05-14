resource "aws_ecs_service" "data" {
  name = "data"
  cluster = "${data.aws_ecs_cluster.default.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.data.arn}"
  desired_count = 1

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.data.id}"
    container_name   = "data"
    container_port   = "80"
  }

  depends_on = [
    "data.aws_lb_listener.default",
  ]
}

resource "aws_ecs_task_definition" "data" {
  family = "data"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "2048"

  container_definitions =  "${data.template_file.data_task.rendered}"
}

resource "aws_lb_target_group" "data" {
  name     = "data"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "data" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 60

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.data.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.data.name}"]
  }
}

resource "aws_route53_record" "data" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "data.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.default.dns_name}"]
}

resource "aws_route53_record" "split-data" {
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "data.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.default.dns_name}"]
}
