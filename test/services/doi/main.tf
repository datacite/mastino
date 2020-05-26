resource "aws_ecs_service" "doi-test" {
  name = "doi-test"
  cluster = data.aws_ecs_cluster.test.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.doi-test.arn
  desired_count = 2

  # give container time to start up
  health_check_grace_period_seconds = 600

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.doi-test.id
    container_name   = "doi-test"
    container_port   = "80"
  }

  // service_registries {
  //   registry_arn = aws_service_discovery_service.doi-test.arn
  // }

  depends_on = [
    "data.aws_lb_listener.test"
  ]
}

resource "aws_cloudwatch_log_group" "doi-test" {
  name = "/ecs/doi-test"
}

resource "aws_ecs_task_definition" "doi-test" {
  family = "doi-test"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "2048"
  memory = "4096"
  container_definitions = templatefile("doi.json",
    {
      orcid_url          = var.orcid_url
      api_url            = var.api_url
      eventdata_url      = var.eventdata_url
      search_url         = var.search_url
      cdn_url            = var.cdn_url
      sentry_dsn         = var.sentry_dsn
      public_key         = var.public_key
      alb_public_key     = var.alb_public_key
      jwt_public_key     = var.jwt_public_key
      jwt_blacklisted    = var.jwt_blacklisted
      tracking_id        = var.tracking_id
      version            = var.bracco_tags["version"]
    })
}

resource "aws_lb_target_group" "doi-test" {
  name     = "doi-test"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/heartbeat"
    interval = 60
    timeout = 30
  }
}

// resource "aws_lb_listener_rule" "doi-test-auth" {
//   listener_arn = data.aws_lb_listener.test.arn
//   priority     = 30

//   action {
//     type = "authenticate-oidc"

//     authenticate_oidc {
//       authorization_endpoint = "https://auth.globus.org/v2/oauth2/authorize"
//       client_id              = var.oidc_client_id
//       client_secret          = var.oidc_client_secret
//       issuer                 = "https://auth.globus.org"
//       token_endpoint         = "https://auth.globus.org/v2/oauth2/token"
//       user_info_endpoint     = "https://auth.globus.org/v2/oauth2/userinfo"
//       on_unauthenticated_request = "authenticate"
//       scope                  = "openid profile email"
//     }
//   }

//   action {
//     type             = "forward"
//     target_group_arn = aws_lb_target_group.doi-test.arn
//   }

//   condition {
//     field  = "host-header"
//     values = [aws_route53_record.doi-test.name]
//   }

//   condition {
//     field  = "path-pattern"
//     values = ["/authorize"]
//   }
// }

resource "aws_lb_listener_rule" "doi-test-clients" {
  listener_arn = data.aws_lb_listener.test.arn
  priority     = 84

  action {
    type = "redirect"

    redirect {
      path        = "/"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }

  condition {
    field  = "path-pattern"
    values = ["/clients*"]
  }
}

resource "aws_lb_listener_rule" "doi-test" {
  listener_arn = data.aws_lb_listener.test.arn
  priority     = 85

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.doi-test.arn
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.doi-test.name]
  }
}

resource "aws_route53_record" "doi-test" {
    zone_id = data.aws_route53_zone.production.zone_id
    name = "doi.test.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.test.dns_name]
}

resource "aws_route53_record" "split-doi-test" {
    zone_id = data.aws_route53_zone.internal.zone_id
    name = "doi.test.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.test.dns_name]
}

resource "aws_service_discovery_service" "doi-test" {
  name = "doi.test"

  health_check_custom_config {
    failure_threshold = 3
  }

  dns_config {
    namespace_id = var.namespace_id
    
    dns_records {
      ttl = 300
      type = "A"
    }
  }
}
