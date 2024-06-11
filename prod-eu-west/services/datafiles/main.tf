resource "aws_ecs_service" "datafiles" {
  name = "datafiles"
  cluster = data.aws_ecs_cluster.default.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.datafiles.arn
  desired_count = 1

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.datafiles.id
    container_name   = "datafiles"
    container_port   = "80"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.datafiles.arn
  }

  depends_on = [
    data.aws_lb_listener.default
  ]
}

resource "aws_cloudwatch_log_group" "datafiles" {
  name = "/ecs/datafiles"
}

resource "aws_ecs_task_definition" "datafiles" {
  family = "datafiles"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"
  container_definitions = templatefile("datafiles.json",
    {
      access_key         = var.access_key
      secret_key         = var.secret_key
      region             = var.region
      database_url       = var.database_url
      jwt_secret_key     = var.jwt_secret_key
      tesem_secret_key   = var.tesem_secret_key
      sentry_dsn         = var.sentry_dsn
      mailgun_api_key    = var.mailgun_api_key
      version            = var.tesem_tags["version"]
      sha                = var.tesem_tags["sha"]
    })
}

resource "aws_lb_target_group" "datafiles" {
  name     = "datafiles"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
    interval = 300
    timeout = 120
  }
}


resource "aws_lb_listener_rule" "datafiles" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 65

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.datafiles.arn
  }

  condition {
    host_header {
      values = [var.dns_name]
    }
  }

}

resource "aws_route53_record" "datafiles" {
    zone_id = data.aws_route53_zone.production.zone_id
    name = "datafiles.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.default.dns_name]
}

resource "aws_route53_record" "split-datafiles" {
    zone_id = data.aws_route53_zone.internal.zone_id
    name = "datafiles.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.default.dns_name]
}

resource "aws_service_discovery_service" "datafiles" {
  name = "datafiles"

  health_check_custom_config {
    failure_threshold = 1
  }

  dns_config {
    namespace_id = var.namespace_id

    dns_records {
      ttl = 300
      type = "A"
    }
  }
}


