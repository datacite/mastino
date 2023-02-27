resource "aws_ecs_service" "analytics-api-test" {
  name = "analytics-api-test"
  cluster = data.aws_ecs_cluster.test.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.analytics-api-test.arn
  desired_count = 1

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.analytics-api-test.id
    container_name   = "analytics-api-test"
    container_port   = "8081"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.analytics-api-test.arn
  }

  depends_on = [
    data.aws_lb_listener.test
  ]
}

resource "aws_cloudwatch_log_group" "analytics-api-test" {
  name = "/ecs/analytics-api-test"
}

resource "aws_ecs_task_definition" "analytics-api-test" {
  family = "analytics-api-test"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"
  container_definitions = templatefile("analytics-api.json",
    {
      datacite_api_url   = var.datacite_api_url
      version            = var.keeshond_tags["sha"]
      analytics_database_dbname    = var.analytics_database_dbname
      analytics_database_host      = var.analytics_database_host
      analytics_database_user      = var.analytics_database_user
      analytics_database_password  = var.analytics_database_password
    })
}

resource "aws_lb_target_group" "analytics-api-test" {
  name     = "analytics-api-test"
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

resource "aws_lb_listener_rule" "api-test" {
  listener_arn = data.aws_lb_listener.test.arn
  priority     = 42

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.analytics-api-test.arn
  }

  condition {
    field  = "host-header"
    values = ["analytics.test.datacite.org"]
  }

  condition {
    field  = "path-pattern"
    values = ["/api*"]
  }
}

resource "aws_service_discovery_service" "analytics-api-test" {
  name = "analytics-api.test"

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
