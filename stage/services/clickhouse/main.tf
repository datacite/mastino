resource "aws_ecs_service" "clickhouse-stage" {
  name = "clickhouse-stage"
  cluster = data.aws_ecs_cluster.stage.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.clickhouse-stage.arn
  desired_count = 1

  # give container time to start up
  health_check_grace_period_seconds = 900

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.clickhouse-stage.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.clickhouse-stage.id
    container_name   = "clickhouse-stage"
    container_port   = "8123"
  }

  depends_on = [
    data.aws_lb_listener.stage
  ]
}

resource "aws_cloudwatch_log_group" "clickhouse-stage" {
  name = "/ecs/clickhouse-stage"
}

resource "aws_ecs_task_definition" "clickhouse-stage" {
  family = "clickhouse-stage"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "2048"
  memory = "4096"

  container_definitions = templatefile("clickhouse.json", {
    access_key         = var.access_key
    secret_key         = var.secret_key
    region             = var.region
    public_key         = var.public_key
  })
}

resource "aws_route53_record" "clickhouse-stage" {
   zone_id = data.aws_route53_zone.production.zone_id
   name = "clickhouse.stage.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [data.aws_lb.stage.dns_name]
}

resource "aws_route53_record" "split-clickhouse-stage" {
    zone_id = data.aws_route53_zone.internal.zone_id
    name = "clickhouse.stage.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.stage.dns_name]
}

resource "aws_lb_target_group" "clickhouse-stage" {
  name     = "clickhouse-stage"
  port     = 8123
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener_rule" "clickhouse-stage" {
  listener_arn = data.aws_lb_listener.stage.arn
  priority     = 130

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.clickhouse-stage.arn
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.clickhouse-stage.name]
  }
}

resource "aws_service_discovery_service" "clickhouse-stage" {
  name = "clickhouse.stage"

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
