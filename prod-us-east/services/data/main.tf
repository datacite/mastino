resource "aws_ecs_service" "data-us" {
  name = "data-us"
  cluster = "${data.aws_ecs_cluster.us.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.data-us.arn}"
  desired_count = 1

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.data-us.id}"
    container_name   = "data-us"
    container_port   = "80"
  }

  depends_on = [
    "data.aws_lb_listener.us",
  ]
}

resource "aws_ecs_task_definition" "data-us" {
  family = "data-us"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "2048"

  container_definitions =  "${data.template_file.data_task.rendered}"
}

resource "aws_lb_target_group" "data-us" {
  name     = "data-us"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "data-us" {
  listener_arn = "${data.aws_lb_listener.us.arn}"
  priority     = 60

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.data-us.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.data-us.name}"]
  }
}

resource "aws_route53_record" "data-us" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "data.test.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.stage.dns_name}"]
}

resource "aws_route53_record" "split-data-us" {
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "data.test.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.stage.dns_name}"]
}
