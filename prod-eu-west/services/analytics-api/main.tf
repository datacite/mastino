resource "aws_ecs_service" "analytics-api" {
  name = "analytics-api"
  cluster = data.aws_ecs_cluster.default.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.analytics-api.arn
  desired_count = 1

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.analytics-api.id
    container_name   = "analytics-api"
    container_port   = "8081"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.analytics-api.arn
  }

  depends_on = [
    data.aws_lb_listener.default
  ]
}

resource "aws_cloudwatch_log_group" "analytics-api" {
  name = "/ecs/analytics-api"
}

resource "aws_ecs_task_definition" "analytics-api" {
  family = "analytics-api"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"
  container_definitions = templatefile("analytics-api.json",
    {
      plausible_url      = var.plausible_url
      datacite_api_url   = var.datacite_api_url
      version            = var.keeshond_tags["version"]
      analytics_database_dbname    = var.analytics_database_dbname
      analytics_database_host      = var.analytics_database_host
      analytics_database_user      = var.analytics_database_user
      analytics_database_password  = var.analytics_database_password
      jwt_public_key = var.jwt_public_key
      jwt = var.jwt
    })
}

resource "aws_lb_target_group" "analytics-api" {
  name     = "analytics-api"
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

resource "aws_lb_listener_rule" "api" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 42

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.analytics-api.arn
  }

  condition {
    field  = "host-header"
    values = ["analytics.datacite.org"]
  }

  condition {
    field  = "path-pattern"
    values = ["/api/metric"]
  }
}

resource "aws_service_discovery_service" "analytics-api" {
  name = "analytics-api"

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
