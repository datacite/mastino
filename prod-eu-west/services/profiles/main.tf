resource "aws_ecs_service" "profiles" {
  name            = "profiles"
  cluster         = data.aws_ecs_cluster.default.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.profiles.arn

  # Create service with 2 instances to start
  desired_count = 2

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.profiles.id
    container_name   = "profiles"
    container_port   = "80"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.profiles.arn
  }

  depends_on = [
    "data.aws_lb_listener.default",
  ]
}

resource "aws_appautoscaling_target" "profiles" {
  max_capacity       = 8
  min_capacity       = 8
  resource_id        = "service/default/${aws_ecs_service.profiles.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "profiles_scale_up" {
  name               = "scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.profiles.resource_id
  scalable_dimension = aws_appautoscaling_target.profiles.scalable_dimension
  service_namespace  = aws_appautoscaling_target.profiles.service_namespace

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

resource "aws_appautoscaling_policy" "profiles_scale_down" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.profiles.resource_id
  scalable_dimension = aws_appautoscaling_target.profiles.scalable_dimension
  service_namespace  = aws_appautoscaling_target.profiles.service_namespace

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

resource "aws_cloudwatch_metric_alarm" "profiles_cpu_scale_up" {
  alarm_name          = "profiles_cpu_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    ClusterName = "default"
    ServiceName = aws_ecs_service.profiles.name
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions     = [aws_appautoscaling_policy.profiles_scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "profiles_cpu_scale_down" {
  alarm_name          = "profiles_cpu_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    ClusterName = "default"
    ServiceName = aws_ecs_service.profiles.name
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions     = [aws_appautoscaling_policy.profiles_scale_down.arn]
}


resource "aws_cloudwatch_log_group" "profiles" {
  name = "/ecs/profiles"
}

resource "aws_ecs_task_definition" "profiles" {
  family                   = "profiles"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "2048"
  container_definitions    = data.template_file.profiles_task.rendered
}

resource "aws_lb_target_group" "profiles" {
  name        = "profiles"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path     = "/heartbeat"
    interval = 30
    timeout  = 10
  }
}

resource "aws_lb_listener_rule" "profiles" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 50

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.profiles.arn
  }

  condition {
    host_header {
      values = [aws_route53_record.profiles.name]
    }
  }
}

resource "aws_lb_listener_rule" "profiles-api-users" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 37

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.profiles.arn
  }

  condition {
    host_header {
      values = ["api.datacite.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/users*"]
    }
  }
}

resource "aws_lb_listener_rule" "profiles-api-claims" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 36

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.profiles.arn
  }

  condition {
    host_header {
      values = ["api.datacite.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/claims*"]
    }
  }
}

resource "aws_lb_listener_rule" "profiles-api-graphql" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 35

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.profiles.arn
  }

  condition {
    host_header {
      values = ["api.datacite.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/profiles/graphql"]
    }
  }
}

resource "aws_route53_record" "profiles" {
  zone_id = data.aws_route53_zone.production.zone_id
  name    = "profiles.datacite.org"
  type    = "CNAME"
  ttl     = var.ttl
  records = [data.aws_lb.default.dns_name]
}

resource "aws_route53_record" "split-profiles" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "profiles.datacite.org"
  type    = "CNAME"
  ttl     = var.ttl
  records = [data.aws_lb.default.dns_name]
}

resource "aws_service_discovery_service" "profiles" {
  name = "profiles"

  health_check_custom_config {
    failure_threshold = 3
  }

  dns_config {
    namespace_id = var.namespace_id

    dns_records {
      ttl  = 300
      type = "A"
    }
  }
}
