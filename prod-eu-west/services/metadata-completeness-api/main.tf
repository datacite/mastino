resource "aws_ecs_service" "metadata-completeness-api" {
  name = "metadata-completeness-api"
  cluster = data.aws_ecs_cluster.default.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.metadata-completeness-api.arn
  desired_count = 1

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.metadata-completeness-api.id
    container_name   = "metadata-completeness-api"
    container_port   = "8080"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.metadata-completeness-api.arn
  }

  depends_on = [
    data.aws_lb_listener.default
  ]
}

resource "aws_cloudwatch_log_group" "metadata-completeness-api" {
  name = "/ecs/metadata-completeness-api"
}

resource "aws_ecs_task_definition" "metadata-completeness-api" {
  family = "metadata-completeness-api"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"
  container_definitions = templatefile("metadata-completeness-api.json",
    {
      version            = var.pekingese_tags["sha"]
      api_port = var.api_port
      opensearch_host = var.opensearch_host
      opensearch_index = var.opensearch_index
    })
}

resource "aws_lb_target_group" "metadata-completeness-api" {
  name     = "metadata-completeness-api"
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

resource "aws_lb_listener_rule" "metadata-completeness-api" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 43

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.metadata-completeness-api.arn
  }

  condition {
    host_header {
      values = ["api.datacite.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/completeness*"]
    }
  }
}

resource "aws_service_discovery_service" "metadata-completeness-api" {
  name = "metadata-completeness-api"

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
