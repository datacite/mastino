resource "aws_s3_bucket" "metrics" {
  bucket = var.s3_bucket
  acl = "public-read"
  policy = data.template_file.metrics-api_s3.rendered
  tags = {
      Name = "metricsApi"
  }
  versioning {
    enabled = true
  }
  lifecycle_rule {
    enabled = true

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = 60
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      days = 365
    }
  }
}

resource "aws_ecs_service" "metrics-api" {
  name            = "metrics-api"
  cluster         = data.aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.metrics-api.arn

  # Create service with 2 instances to start
  desired_count = 2

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = ["desired_count"]
  }

  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.metrics-api.id
    container_name   = "metrics-api"
    container_port   = "80"
  }

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

   service_registries {
    registry_arn = aws_service_discovery_service.metrics-api.arn
  }

    depends_on = [
    "data.aws_lb_listener.default",
  ]

}

resource "aws_appautoscaling_target" "metrics-api" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "service/default/${aws_ecs_service.metrics-api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "metrics-api_scale_up" {
  name               = "scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.metrics-api.resource_id
  scalable_dimension = aws_appautoscaling_target.metrics-api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.metrics-api.service_namespace

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

resource "aws_appautoscaling_policy" "metrics-api_scale_down" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.metrics-api.resource_id
  scalable_dimension = aws_appautoscaling_target.metrics-api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.metrics-api.service_namespace

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

resource "aws_cloudwatch_metric_alarm" "metrics-api_cpu_scale_up" {
  alarm_name          = "metrics-api_cpu_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    ClusterName = "default"
    ServiceName = aws_ecs_service.metrics-api.name
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions     = [aws_appautoscaling_policy.metrics-api_scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "metrics-api_cpu_scale_down" {
  alarm_name          = "metrics-api_cpu_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    ClusterName = "default"
    ServiceName = aws_ecs_service.metrics-api.name
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions     = [aws_appautoscaling_policy.metrics-api_scale_down.arn]
}

resource "aws_lb_target_group" "metrics-api" {
  name     = "metrics-api"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"


  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "metrics-api" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 19

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.metrics-api.arn
  }

  condition {
    host_header {
      values = ["api.datacite.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/reports*"]
    }
  }
}

resource "aws_lb_listener_rule" "metrics-api-subset" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 18

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.metrics-api.arn
  }

  condition {
    host_header {
      values = ["api.datacite.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/report-subsets*"]
    }
  }
}

resource "aws_lb_listener_rule" "metrics-api--repositories" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 28

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.metrics-api.arn
  }

  condition {
    host_header {
      values = ["api.datacite.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/repositories-usage-reports*"]
    }
  }
}

resource "aws_cloudwatch_log_group" "metrics-api" {
  name = "/ecs/metrics-api"
}

resource "aws_ecs_task_definition" "metrics-api" {
  family = "metrics-api"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  container_definitions =  data.template_file.metrics-api_task.rendered
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "4096"
}

resource "aws_route53_record" "metrics-api" {
  zone_id = data.aws_route53_zone.production.zone_id
  name = "metrics.datacite.org"
  type = "CNAME"
  ttl = var.ttl
  records = [data.aws_lb.default.dns_name]
}

resource "aws_route53_record" "split-metrics-api" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name = "metrics.datacite.org"
  type = "CNAME"
  ttl = var.ttl
  records = [data.aws_lb.default.dns_name]
}

resource "aws_service_discovery_service" "metrics-api" {
  name = "metrics-api"

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
