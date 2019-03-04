resource "aws_ecs_service" "api" {
  name = "api"
  cluster = "${data.aws_ecs_cluster.default.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.api.arn}"
  desired_count = 2
  deployment_minimum_healthy_percent = 50

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.api.id}"
    container_name   = "api"
    container_port   = "80"
  }

  depends_on = [
    "data.aws_lb_listener.default",
  ]
}

resource "aws_cloudwatch_log_group" "api" {
  name = "/ecs/api"
}

resource "aws_ecs_task_definition" "api" {
  family = "api"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "1024"

  container_definitions =  "${data.template_file.api_task.rendered}"
}

resource "aws_lb_target_group" "api" {
  name     = "api"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

// resource "aws_lb_listener_rule" "api-works" {
//   listener_arn = "${data.aws_lb_listener.default.arn}"
//   priority     = 21

//   action {
//     type             = "forward"
//     target_group_arn = "${aws_lb_target_group.api.arn}"
//   }

//   condition {
//     field  = "host-header"
//     values = ["${aws_route53_record.api.name}"]
//   }
//   condition {
//     field  = "path-pattern"
//     values = ["/works*"]
//   }
// }

resource "aws_lb_listener_rule" "api-pages" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 22

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.api.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.api.name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/pages*"]
  }
}

resource "aws_lb_listener_rule" "api-milestones" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 23

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.api.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.api.name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/milestones*"]
  }
}

resource "aws_lb_listener_rule" "api-user-stories" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 24

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.api.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.api.name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/user-stories*"]
  }
}

resource "aws_lb_listener_rule" "api-datasets" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 25

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.api.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.api.name}"]
  }
  condition {
    field  = "path-pattern"
    values = ["/datasets*"]
  }
}

// resource "aws_lb_listener_rule" "api-data-centers" {
//   listener_arn = "${data.aws_lb_listener.default.arn}"
//   priority     = 26

//   action {
//     type             = "forward"
//     target_group_arn = "${aws_lb_target_group.api.arn}"
//   }

//   condition {
//     field  = "host-header"
//     values = ["${aws_route53_record.api.name}"]
//   }
//   condition {
//     field  = "path-pattern"
//     values = ["/data-centers*"]
//   }
// }

// resource "aws_lb_listener_rule" "api-members" {
//   listener_arn = "${data.aws_lb_listener.default.arn}"
//   priority     = 27

//   action {
//     type             = "forward"
//     target_group_arn = "${aws_lb_target_group.api.arn}"
//   }

//   condition {
//     field  = "host-header"
//     values = ["${aws_route53_record.api.name}"]
//   }
//   condition {
//     field  = "path-pattern"
//     values = ["/members*"]
//   }
// }

resource "aws_route53_record" "api" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "api.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.default.dns_name}"]
}

resource "aws_route53_record" "split-api" {
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "api.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.default.dns_name}"]
}
