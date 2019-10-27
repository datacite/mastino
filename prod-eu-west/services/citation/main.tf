resource "aws_ecs_service" "citation" {
  name = "citation"
  cluster = "${data.aws_ecs_cluster.default.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.citation.arn}"
  desired_count = 2

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.citation.id}"
    container_name   = "citation"
    container_port   = "80"
  }

  depends_on = [
    "data.aws_lb_listener.default",
  ]
}

resource "aws_cloudwatch_log_group" "citation" {
  name = "/ecs/citation"
}

resource "aws_ecs_task_definition" "citation" {
  family = "citation"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "2048"

  container_definitions =  "${data.template_file.citation_task.rendered}"
}

resource "aws_lb_target_group" "citation" {
  name     = "citation"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener_rule" "citation" {
  listener_arn = "${data.aws_lb_listener.crosscite.arn}"
  priority     = 70

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.citation.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.citation.name}"]
  }
}

resource "aws_route53_record" "crosscite-apex" {
  zone_id = "${data.aws_route53_zone.crosscite.zone_id}"
  name = "crosscite.org"
  type = "A"

  alias {
    name = "${data.aws_lb.crosscite.dns_name}"
    zone_id = "${data.aws_lb.crosscite.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "crosscite-www" {
  zone_id = "${data.aws_route53_zone.crosscite.zone_id}"
  name = "www.crosscite.org"
  type = "A"

  alias {
    name = "${data.aws_lb.crosscite.dns_name}"
    zone_id = "${data.aws_lb.crosscite.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "citation" {
    zone_id = "${data.aws_route53_zone.crosscite.zone_id}"
    name = "citation.crosscite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.crosscite.dns_name}"]
}

resource "aws_route53_record" "split-citation" {
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "citation.crosscite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.crosscite.dns_name}"]
}
