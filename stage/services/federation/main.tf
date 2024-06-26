resource "aws_ecs_service" "federation-stage" {
  name = "federation-stage"
  cluster = data.aws_ecs_cluster.stage.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.federation-stage.arn
  desired_count = 1

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.federation-stage.id
    container_name   = "federation-stage"
    container_port   = "80"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.federation-stage.arn
  }

  depends_on = [
    "data.aws_lb_listener.stage"
  ]
}

resource "aws_cloudwatch_log_group" "federation-stage" {
  name = "/ecs/federation-stage"
}

resource "aws_ecs_task_definition" "federation-stage" {
  family = "federation-stage"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"

  container_definitions =  data.template_file.federation_task.rendered
}

resource "aws_lb_target_group" "federation-stage" {
  name     = "federation-stage"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/.well-known/apollo/server-health"
  }
}

resource "aws_lb_listener_rule" "federation-stage" {
  listener_arn = data.aws_lb_listener.stage.arn
  priority     = 49

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.federation-stage.arn
  }

  condition {
    host_header {
      values = [var.api_dns_name]
    }
  }

  condition {
    path_pattern {
      values = ["/graphql"]
    }
  }
}

resource "aws_service_discovery_service" "federation-stage" {
  name = "federation.stage"

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
