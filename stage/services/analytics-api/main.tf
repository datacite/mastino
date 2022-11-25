resource "aws_ecs_service" "analytics-api-stage" {
  name = "analytics-api-stage"
  cluster = data.aws_ecs_cluster.stage.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.analytics-api-stage.arn
  desired_count = 1

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.analytics-api-stage.id
    container_name   = "analytics-api-stage"
    container_port   = "8081"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.analytics-api-stage.arn
  }

  depends_on = [
    data.aws_lb_listener.stage
  ]
}

resource "aws_cloudwatch_log_group" "analytics-api-stage" {
  name = "/ecs/analytics-api-stage"
}

resource "aws_ecs_task_definition" "analytics-api-stage" {
  family = "analytics-api-stage"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"
  container_definitions = templatefile("analytics-api.json",
    {
      plausible_url      = var.plausible_url
      datacite_api_url   = var.datacite_api_url
      version            = var.keeshond_tags["sha"]
    })
}

resource "aws_lb_target_group" "analytics-api-stage" {
  name     = "analytics-api-stage"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/heartbeat"
    interval = 300
    timeout = 120
  }
}

resource "aws_lb_listener_rule" "api-stage" {
  listener_arn = data.aws_lb_listener.stage.arn
  priority     = 42

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.analytics-api-stage.arn
  }

  condition {
    field  = "host-header"
    values = ["analytics.stage.datacite.org"]
  }

  condition {
    field  = "path-pattern"
    values = ["/api/"]
  }
}

resource "aws_service_discovery_service" "analytics-api-stage" {
  name = "analytics-api.stage"

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
