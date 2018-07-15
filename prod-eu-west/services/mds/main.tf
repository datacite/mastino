resource "aws_ecs_service" "mds" {
  name = "mds"
  cluster = "${data.aws_ecs_cluster.default.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.mds.arn}"
  desired_count = 2

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.mds.id}"
    container_name   = "mds"
    container_port   = "80"
  }

  depends_on = [
    "data.aws_lb_listener.default",
  ]
}

resource "aws_cloudwatch_log_group" "mds" {
  name = "/ecs/mds"
}

resource "aws_ecs_task_definition" "mds" {
  family = "mds"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}",
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "1024"
  memory = "2048"

  container_definitions =  "${data.template_file.mds_task.rendered}"
}

resource "aws_lb_target_group" "mds" {
  name     = "mds"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "mds-doi" {
  listener_arn = "${data.aws_lb_listener.alternate.arn}"
  priority     = 6

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.mds.arn}"
  }

  condition {
    field  = "host-header"
    values = ["mds.datacite.org"]
  }
  
  condition {
    field  = "path-pattern"
    values = ["/doi*"]
  }
}

resource "aws_lb_listener_rule" "mds-metadata" {
  listener_arn = "${data.aws_lb_listener.alternate.arn}"
  priority     = 7

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.mds.arn}"
  }

  condition {
    field  = "host-header"
    values = ["mds.datacite.org"]
  }

  condition {
    field  = "path-pattern"
    values = ["/metadata*"]
  }
}

resource "aws_lb_listener_rule" "mds-media" {
  listener_arn = "${data.aws_lb_listener.alternate.arn}"
  priority     = 8

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.mds.arn}"
  }

  condition {
    field  = "host-header"
    values = ["mds.datacite.org"]
  }

  condition {
    field  = "path-pattern"
    values = ["/media*"]
  }
}

resource "aws_lb_listener_rule" "mds-heartbeat" {
  listener_arn = "${data.aws_lb_listener.alternate.arn}"
  priority     = 9

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.mds.arn}"
  }

  condition {
    field  = "host-header"
    values = ["mds.datacite.org"]
  }

  condition {
    field  = "path-pattern"
    values = ["/heartbeat"]
  }
}

resource "aws_lb_listener_rule" "mds-ng" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 12

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.mds-legacy.arn}"
  }

  condition {
    field  = "host-header"
    values = ["mds.datacite.org"]
  }
}

resource "aws_route53_record" "mds-ng" {
   zone_id = "${data.aws_route53_zone.production.zone_id}"
   name = "mds-ng.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.default.dns_name}"]
}

resource "aws_route53_record" "split-mds-ng" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "mds-ng.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.default.dns_name}"]
}

resource "aws_route53_record" "mds-legacy-rr" {
  zone_id = "${data.aws_route53_zone.production.zone_id}"
  name    = "mds.datacite.org"
  type    = "CNAME"
  ttl     = "${var.ttl}"

  weighted_routing_policy {
    weight = 95
  }

  set_identifier = "legacy"
  records        = ["${data.aws_lb.default.dns_name}"]
}

resource "aws_route53_record" "mds-ng-rr" {
  zone_id = "${data.aws_route53_zone.production.zone_id}"
  name    = "mds.datacite.org"
  type    = "CNAME"
  ttl     = "${var.ttl}"

  weighted_routing_policy {
    weight = 5
  }

  set_identifier = "ng"
  records        = ["${data.aws_lb.alternate.dns_name}"]
}

resource "aws_route53_record" "split-mds-legacy-rr" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name    = "mds.datacite.org"
  type    = "CNAME"
  ttl     = "5"

  weighted_routing_policy {
    weight = 95
  }

  set_identifier = "split-legacy"
  records        = ["${data.aws_lb.default.dns_name}"]
}

resource "aws_route53_record" "split-mds-ng-rr" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name    = "mds.datacite.org"
  type    = "CNAME"
  ttl     = "5"

  weighted_routing_policy {
    weight = 5
  }

  set_identifier = "split-ng"
  records        = ["${data.aws_lb.alternate.dns_name}"]
}