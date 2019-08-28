resource "aws_ecs_service" "doi" {
  name = "doi"
  cluster = "${data.aws_ecs_cluster.default.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.doi.arn}"
  desired_count = 8

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.doi.id}"
    container_name   = "doi"
    container_port   = "80"
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.doi.arn}"
  }

  depends_on = [
    "data.aws_lb_listener.default",
  ]
}

resource "aws_cloudwatch_log_group" "doi" {
  name = "/ecs/doi"
}

resource "aws_ecs_task_definition" "doi" {
  family = "doi"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "2048"
  memory = "4096"

  container_definitions =  "${data.template_file.doi_task.rendered}"
}

resource "aws_lb_target_group" "doi" {
  name     = "doi"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "doi-auth" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 30

  action {
    type = "authenticate-oidc"

    authenticate_oidc {
      authorization_endpoint = "https://auth.globus.org/v2/oauth2/authorize"
      client_id              = "${var.oidc_client_id}"
      client_secret          = "${var.oidc_client_secret}"
      issuer                 = "https://auth.globus.org"
      token_endpoint         = "https://auth.globus.org/v2/oauth2/token"
      user_info_endpoint     = "https://auth.globus.org/v2/oauth2/userinfo"
      on_unauthenticated_request = "authenticate"
      scope                  = "openid profile email"
    }
  }

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.doi.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.doi.name}"]
  }

  condition {
    field  = "path-pattern"
    values = ["/authorize"]
  }
}

resource "aws_lb_listener_rule" "doi" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 85

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.doi.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.doi.name}"]
  }
}

resource "aws_route53_record" "doi" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "doi.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.default.dns_name}"]
}

resource "aws_route53_record" "split-doi" {
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "doi.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.default.dns_name}"]
}

resource "aws_service_discovery_service" "doi" {
  name = "doi"

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
