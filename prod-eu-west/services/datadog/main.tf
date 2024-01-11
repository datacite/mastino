resource "aws_ecs_service" "datadog" {
  name = "datadog"
  cluster = data.aws_ecs_cluster.default.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.datadog.arn
  desired_count = 1

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.datadog.arn
  }
}

resource "aws_cloudwatch_log_group" "datadog" {
  name = "/ecs/datadog"
}

resource "aws_ecs_task_definition" "datadog" {
  family = "datadog"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"

  container_definitions =  data.template_file.datadog_task.rendered
}

resource "aws_service_discovery_service" "datadog" {
  name = "datadog"

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
