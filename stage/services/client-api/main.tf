resource "aws_ecs_service" "client-api-stage" {
  name = "client-api-stage"
  cluster = "${data.aws_ecs_cluster.stage.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.client-api-stage.arn}"
  desired_count = 1

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.client-api-stage.id}"
    container_name   = "client-api-stage"
    container_port   = "80"
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.client-api-stage.arn}"
  }

  depends_on = [
    "data.aws_lb_listener.stage",
  ]
}

resource "aws_cloudwatch_log_group" "client-api-stage" {
  name = "/ecs/client-api-stage"
}

resource "aws_ecs_task_definition" "client-api-stage" {
  family = "client-api-stage"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "1024"
  memory = "2048"
  container_definitions =  "${data.template_file.client-api_task.rendered}"
}

resource "aws_lb_target_group" "client-api-stage" {
  name     = "client-api-stage"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "api-stage-oidc-token" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
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
    target_group_arn = "${aws_lb_target_group.client-api-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.api_dns_name}"]
  }

  condition {
    field  = "path-pattern"
    values = ["/oidc-token"]
  }
}

resource "aws_lb_listener_rule" "api-stage" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
  priority     = 33

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.client-api-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.api_dns_name}"]
  }
}

resource "aws_service_discovery_service" "client-api-stage" {
  name = "client-api.test"

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
