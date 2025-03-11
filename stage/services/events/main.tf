resource "aws_ecs_service" "events-stage" {
  name            = "events-stage"
  cluster         = data.aws_ecs_cluster.stage.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.events-stage.arn
  desired_count   = 1

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.events-stage.id
    container_name   = "events-stage"
    container_port   = "80"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.events-stage.arn
  }

  depends_on = [
    data.aws_lb_listener.stage
  ]
}

resource "aws_cloudwatch_log_group" "events-stage" {
  name = "/ecs/events-stage"
}

resource "aws_ecs_task_definition" "events-stage" {
  family                   = "events-stage"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "2048"
  container_definitions = templatefile("events.json",
    {
      re3data_url                       = var.re3data_url
      bracco_url                        = var.bracco_url
      public_key                        = var.public_key
      jwt_public_key                    = var.jwt_public_key
      jwt_private_key                   = var.jwt_private_key
      session_encrypted_cookie_salt     = var.session_encrypted_cookie_salt
      mysql_user                        = var.mysql_user
      mysql_password                    = var.mysql_password
      mysql_database                    = var.mysql_database
      mysql_host                        = var.mysql_host
      es_name                           = var.es_name
      es_host                           = var.es_host
      es_scheme                         = var.es_scheme
      es_port                           = var.es_port
      es_prefix                         = var.es_prefix
      elastic_password                  = var.elastic_password
      handle_url                        = var.handle_url
      handle_username                   = var.handle_username
      handle_password                   = var.handle_password
      admin_username                    = var.admin_username
      admin_password                    = var.admin_password
      access_key                        = var.api_aws_access_key
      secret_key                        = var.api_aws_secret_key
      region                            = var.region
      s3_bucket                         = var.s3_bucket
      sentry_dsn                        = var.sentry_dsn
      mailgun_api_key                   = var.mailgun_api_key
      memcache_servers                  = var.memcache_servers
      jwt_blacklisted                   = var.jwt_blacklisted
      slack_webhook_url                 = var.slack_webhook_url
      version                           = var.events_tags["version"]
      sha                               = var.events_tags["sha"]
      plugin_openapi_url                = var.plugin_openapi_url
      plugin_manifest_url               = var.plugin_manifest_url
      exclude_prefixes_from_data_import = var.exclude_prefixes_from_data_import
  })
}

resource "aws_lb_target_group" "events-stage" {
  name        = "events-stage"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path     = "/heartbeat"
    interval = 300
    timeout  = 120
  }
}

resource "aws_lb_listener_rule" "events-stage" {
  listener_arn = data.aws_lb_listener.stage.arn
  priority     = 55

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.events-stage.arn
  }

  condition {
    host_header {
      values = [var.api_dns_name]
    }
  }

}

resource "aws_service_discovery_service" "events-stage" {
  name = "events.stage"

  health_check_custom_config {
    failure_threshold = 3
  }

  dns_config {
    namespace_id = var.namespace_id

    dns_records {
      ttl  = 300
      type = "A"
    }
  }
}

resource "aws_route53_record" "events-stage" {
  zone_id = data.aws_route53_zone.production.zone_id
  name    = "events.stage.datacite.org"
  type    = "CNAME"
  ttl     = var.ttl
  records = [data.aws_lb.stage.dns_name]
}

resource "aws_route53_record" "split-events-stage" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "events.stage.datacite.org"
  type    = "CNAME"
  ttl     = var.ttl
  records = [data.aws_lb.stage.dns_name]
}
