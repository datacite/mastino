resource "aws_ecs_service" "profiles" {
  name = "profiles"
  cluster = "${data.aws_ecs_cluster.default.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.profiles.arn}"
  desired_count = 2

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.profiles.id}"
    container_name   = "profiles"
    container_port   = "80"
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.profiles.arn}"
  }

  depends_on = [
    "data.aws_lb_listener.default",
  ]
}

resource "aws_cloudwatch_log_group" "profiles" {
  name = "/ecs/profiles"
}

resource "aws_ecs_task_definition" "profiles" {
  family = "profiles"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "1024"
  memory = "2048"
  container_definitions =  "${data.template_file.profiles_task.rendered}"
}

resource "aws_lb_target_group" "profiles" {
  name     = "profiles"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "profiles" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
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

resource "aws_lb_listener_rule" "profiles-api--users" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 51

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.profiles.arn}"
  }

  condition {
    field  = "host-header"
    values = ["api.datacite.org"]
  }

  condition {
    field  = "path-pattern"
    values = ["/users*"]
  }
}

resource "aws_lb_listener_rule" "profiles-api-claims" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 52

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.profiles.arn}"
  }

  condition {
    field  = "host-header"
    values = ["api.datacite.org"]
  }

  condition {
    field  = "path-pattern"
    values = ["/claims*"]
  }
}

resource "aws_lb_listener_rule" "profiles-api-graphql" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 53

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.profiles.arn}"
  }

  condition {
    field  = "host-header"
    values = ["api.datacite.org"]
  }

  condition {
    field  = "path-pattern"
    values = ["/profiles/graphql"]
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

resource "aws_service_discovery_service" "profiles" {
  name = "profiles"

  health_check_custom_config {
    failure_threshold = 3
  }

  dns_config {
    namespace_id = "${var.namespace_id}"
    
    dns_records {
      ttl = 300
      type = "A"
    }
  }
}
