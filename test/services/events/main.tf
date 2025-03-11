resource "aws_ecs_service" "events-test" {
  name            = "events-test"
  cluster         = data.aws_ecs_cluster.test.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.events-test.arn
  desired_count   = 2

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.events-test.id
    container_name   = "events-test"
    container_port   = "80"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.events-test.arn
  }

  depends_on = [
    data.aws_lb_listener.test
  ]
}

resource "aws_cloudwatch_log_group" "events-test" {
  name = "/ecs/events-test"
}

resource "aws_ecs_task_definition" "events-test" {
  family                   = "events-test"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "4096"
  container_definitions = templatefile("events.json",
    {
      re3data_url                   = var.re3data_url
      bracco_url                    = var.bracco_url
      jwt_public_key                = var.jwt_public_key
      jwt_private_key               = var.jwt_private_key
      session_encrypted_cookie_salt = var.session_encrypted_cookie_salt
      handle_url                    = var.handle_url
      handle_username               = var.handle_username
      handle_password               = var.handle_password
      mysql_user                    = var.mysql_user
      mysql_password                = var.mysql_password
      mysql_database                = var.mysql_database
      mysql_host                    = var.mysql_host
      es_name                       = var.es_name
      es_host                       = var.es_host
      es_scheme                     = var.es_scheme
      es_port                       = var.es_port
      es_prefix                     = var.es_prefix
      elastic_password              = var.elastic_password
      public_key                    = var.public_key
      access_key                    = var.api_aws_access_key
      secret_key                    = var.api_aws_secret_key
      region                        = var.region
      s3_bucket                     = var.s3_bucket
      admin_username                = var.admin_username
      admin_password                = var.admin_password
      sentry_dsn                    = var.sentry_dsn
      mailgun_api_key               = var.mailgun_api_key
      memcache_servers              = var.memcache_servers
      slack_webhook_url             = var.slack_webhook_url
      jwt_blacklisted               = var.jwt_blacklisted
      version                       = var.events_tags["version"]
  })
}

resource "aws_lb_target_group" "events-test" {
  name        = "events-test"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path     = "/heartbeat"
    timeout  = 30
    interval = 60
  }
}

resource "aws_lb_listener_rule" "api-test" {
  listener_arn = data.aws_lb_listener.test.arn
  priority     = 54

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.events-test.arn
  }

  condition {
    host_header {
      values = [var.api_dns_name]
    }
  }
}

resource "aws_route53_record" "api-test" {
  zone_id = data.aws_route53_zone.production.zone_id
  name    = "api.test.datacite.org"
  type    = "CNAME"
  ttl     = var.ttl
  records = [data.aws_lb.test.dns_name]
}

resource "aws_route53_record" "split-api-test" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "api.test.datacite.org"
  type    = "CNAME"
  ttl     = var.ttl
  records = [data.aws_lb.test.dns_name]
}

resource "aws_service_discovery_service" "events-test" {
  name = "events.test"

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
