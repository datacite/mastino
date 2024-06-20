resource "aws_ecs_service" "levriero" {
  name = "levriero"
  cluster = data.aws_ecs_cluster.default.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.levriero.arn

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
    target_group_arn = aws_lb_target_group.levriero.id
    container_name   = "levriero"
    container_port   = "80"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.levriero.arn
  }

  depends_on = [
    data.aws_lb_listener.default,
  ]
}

resource "aws_appautoscaling_target" "levriero" {
  max_capacity       = 32
  min_capacity       = 32
  resource_id        = "service/default/${aws_ecs_service.levriero.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "levriero_scale_up" {
  name               = "scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.levriero.resource_id
  scalable_dimension = aws_appautoscaling_target.levriero.scalable_dimension
  service_namespace  = aws_appautoscaling_target.levriero.service_namespace

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

resource "aws_appautoscaling_policy" "levriero_scale_down" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.levriero.resource_id
  scalable_dimension = aws_appautoscaling_target.levriero.scalable_dimension
  service_namespace  = aws_appautoscaling_target.levriero.service_namespace

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

resource "aws_cloudwatch_metric_alarm" "levriero_cpu_scale_up" {
  alarm_name          = "levriero_cpu_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    ClusterName = "default"
    ServiceName = aws_ecs_service.levriero.name
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions     = [aws_appautoscaling_policy.levriero_scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "levriero_cpu_scale_down" {
  alarm_name          = "levriero_cpu_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    ClusterName = "default"
    ServiceName = aws_ecs_service.levriero.name
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions     = [aws_appautoscaling_policy.levriero_scale_down.arn]
}

resource "aws_cloudwatch_log_group" "levriero" {
  name = "/ecs/levriero"
}

resource "aws_ecs_task_definition" "levriero" {
  family = "levriero"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "2048"
  memory = "4096"
  container_definitions =  data.template_file.levriero_task.rendered
}

resource "aws_lb_target_group" "levriero" {
  name     = "levriero"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "levriero" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 17

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.levriero.arn
  }

  condition {
    host_header {
      values = [var.api_dns_name]
    }
  }

  condition {
    path_pattern {
      values = ["/agents*"]
    }
  }
}

resource "aws_service_discovery_service" "levriero" {
  name = "levriero"

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
