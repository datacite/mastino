locals {
  full_app_name = "${var.app_name}-${var.env}"
  discovery_name = "${var.app_name}.${var.env}"
  log_group_name = "/ecs/${local.full_app_name}"
  task_family    = local.full_app_name
}

data "aws_ecs_cluster" "ecs_cluster" {
  cluster_name = var.env
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

data "aws_security_group" "datacite-private" {
  id = var.security_group_id
}

data "aws_subnet" "datacite-private" {
  id = var.subnet_datacite-private_id
}

data "aws_subnet" "datacite-alt" {
  id = var.subnet_datacite-alt_id
}


resource "aws_cloudwatch_log_group" "log_group" {
  name = local.log_group_name
}

resource "aws_ecs_service" "ecs-service" {
  name            = local.full_app_name
  cluster         = data.aws_ecs_cluster.ecs_cluster.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = var.task_desired_count

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.service_discovery.arn
  }

  # Optional load balancer attached

  dynamic "load_balancer" {
    for_each = var.load_balancer_config
    
    iterator = lb
    
    content {
      target_group_arn = lb.value.target_group_arn
      container_name   = local.full_app_name
      container_port   = lb.value.container_port
    }
  }

}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family = local.task_family
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = var.task_cpu
  memory = var.task_memory

  container_definitions = var.container_definition_json
}


resource "aws_service_discovery_service" "service_discovery" {
  name = local.discovery_name

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

