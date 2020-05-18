resource "aws_ecs_service" "akita-stage" {
  name = "akita-stage"
  cluster = data.aws_ecs_cluster.stage.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.akita-stage.arn
  desired_count = 1

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
    target_group_arn = aws_lb_target_group.akita-stage.id
    container_name   = "akita-stage"
    container_port   = "80"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.akita-stage.arn
  }

  depends_on = [
    data.aws_lb_listener.stage
  ]
}

resource "aws_cloudwatch_log_group" "akita-stage" {
  name = "/ecs/akita-stage"
}

resource "aws_ecs_task_definition" "akita-stage" {
  family = "akita-stage"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "1024"
  memory = "2048"
  container_definitions = templatefile("akita.json",
    {
      sentry_dsn         = var.sentry_dsn
      tracking_id        = var.tracking_id
      version            = var.akita_tags["sha"]
    })
}

resource "aws_lb_target_group" "akita-stage" {
  name     = "akita-stage"
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

resource "aws_lb_listener_rule" "akita-stage" {
  listener_arn = data.aws_lb_listener.stage.arn
  priority     = 85

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.akita-stage.arn
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.akita-stage.name]
  }
}

resource "aws_route53_record" "akita-stage" {
    zone_id = data.aws_route53_zone.production.zone_id
    name = "common.test.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.stage.dns_name]
}

resource "aws_route53_record" "split-akita-stage" {
    zone_id = data.aws_route53_zone.internal.zone_id
    name = "common.test.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.stage.dns_name]
}

resource "aws_service_discovery_service" "akita-stage" {
  name = "akita.test"

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
