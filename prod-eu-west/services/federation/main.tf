resource "aws_ecs_service" "federation" {
  name = "federation"
  cluster = data.aws_ecs_cluster.default.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.federation.arn

  # Create service with 2 instances to start
  desired_count = 2

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.federation.id
    container_name   = "federation"
    container_port   = "80"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.federation.arn
  }

  depends_on = [
    data.aws_lb_listener.default,
  ]
}

resource "aws_appautoscaling_target" "federation" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "service/default/${aws_ecs_service.federation.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "federation_scale_up" {
  name               = "scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.federation.resource_id
  scalable_dimension = aws_appautoscaling_target.federation.scalable_dimension
  service_namespace  = aws_appautoscaling_target.federation.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "federation_scale_down" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.federation.resource_id
  scalable_dimension = aws_appautoscaling_target.federation.scalable_dimension
  service_namespace  = aws_appautoscaling_target.federation.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "federation_cpu_scale_up" {
  alarm_name          = "federation_cpu_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    ClusterName = "default"
    ServiceName = aws_ecs_service.federation.name
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions     = [aws_appautoscaling_policy.federation_scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "federation_cpu_scale_down" {
  alarm_name          = "federation_cpu_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    ClusterName = "default"
    ServiceName = aws_ecs_service.federation.name
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions     = [aws_appautoscaling_policy.federation_scale_down.arn]
}

resource "aws_cloudwatch_log_group" "federation" {
  name = "/ecs/federation"
}

resource "aws_ecs_task_definition" "federation" {
  family = "federation"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"

  container_definitions =  data.template_file.federation_task.rendered
}

resource "aws_lb_target_group" "federation" {
  name     = "federation"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/.well-known/apollo/server-health"
  }
}

resource "aws_lb_listener_rule" "federation" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 38

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.federation.arn
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

resource "aws_lb_listener_rule" "federation-healthcheck" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 33

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.federation.arn
  }

  condition {
    host_header {
      values = [var.api_dns_name]
    }
  }

  condition {
    path_pattern {
      values = ["/.well-known/apollo/server-health"]
    }
  }
}

resource "aws_service_discovery_service" "federation" {
  name = "federation"

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
