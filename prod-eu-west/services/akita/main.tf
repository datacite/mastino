resource "aws_ecs_service" "akita" {
  name = "akita"
  cluster = data.aws_ecs_cluster.default.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.akita.arn
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
    target_group_arn = aws_lb_target_group.akita.id
    container_name   = "akita"
    container_port   = "80"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.akita.arn
  }

  depends_on = [
    data.aws_lb_listener.default
  ]
}

resource "aws_cloudwatch_log_group" "akita" {
  name = "/ecs/akita"
}

resource "aws_ecs_task_definition" "akita" {
  family = "akita"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "1024"
  memory = "2048"
  container_definitions = templatefile("akita.json",
    {
      sentry_dsn           = var.sentry_dsn
      tracking_id          = var.tracking_id
      next_public_title    = var.next_public_title
      next_public_api_url  = var.next_public_api_url
      version              = var.akita_tags["version"]
    })
}

resource "aws_lb_target_group" "akita" {
  name     = "akita"
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

resource "aws_lb_listener_rule" "akita" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 86

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.akita.arn
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.akita.name]
  }
}

resource "aws_route53_record" "akita" {
    zone_id = data.aws_route53_zone.production.zone_id
    name = "commons.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.default.dns_name]
}

resource "aws_route53_record" "split-akita" {
    zone_id = data.aws_route53_zone.internal.zone_id
    name = "commons.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.default.dns_name]
}

resource "aws_service_discovery_service" "akita" {
  name = "akita"

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