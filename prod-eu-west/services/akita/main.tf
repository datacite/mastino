resource "aws_ecs_service" "akita" {
  name = "akita"
  cluster = data.aws_ecs_cluster.default.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.akita.arn

  # Create service with 2 instances to start
  desired_count = 0

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [desired_count]
  }

  # give container time to start up
  health_check_grace_period_seconds = 900

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.akita.id
    container_name   = "akita"
    container_port   = "80"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.akita.arn
  }

  depends_on = [
    data.aws_lb_listener.default
  ]
}

resource "aws_appautoscaling_target" "akita" {
  max_capacity       = 8
  min_capacity       = 2
  resource_id        = "service/default/${aws_ecs_service.akita.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "akita_scale_up" {
  name               = "scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.akita.resource_id
  scalable_dimension = aws_appautoscaling_target.akita.scalable_dimension
  service_namespace  = aws_appautoscaling_target.akita.service_namespace

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

resource "aws_appautoscaling_policy" "akita_scale_down" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.akita.resource_id
  scalable_dimension = aws_appautoscaling_target.akita.scalable_dimension
  service_namespace  = aws_appautoscaling_target.akita.service_namespace

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

resource "aws_cloudwatch_metric_alarm" "akita_cpu_scale_up" {
  alarm_name          = "akita_cpu_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    ClusterName = "default"
    ServiceName = aws_ecs_service.akita.name
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions     = [aws_appautoscaling_policy.akita_scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "akita_cpu_scale_down" {
  alarm_name          = "akita_cpu_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    ClusterName = "default"
    ServiceName = aws_ecs_service.akita.name
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions     = [aws_appautoscaling_policy.akita_scale_down.arn]
}

resource "aws_cloudwatch_log_group" "akita" {
  name = "/ecs/akita"
}

resource "aws_ecs_task_definition" "akita" {
  family = "akita"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "1024"
  memory = "2048"
  container_definitions = templatefile("akita.json",
    {
      sentry_dsn           = var.sentry_dsn
      public_key           = var.public_key
      next_public_api_url  = var.next_public_api_url
      next_public_ga_tracking_id = var.next_public_ga_tracking_id
      next_public_profiles_url = var.next_public_profiles_url
      next_public_jwt_public_key = var.next_public_jwt_public_key
      sitemaps_url         = var.sitemaps_url
      sitemaps_bucket_url  = var.sitemaps_bucket_url
      version              = var.akita_tags["version"]
    })
}

resource "aws_lb_target_group" "akita" {
  name     = "akita"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/heartbeat"
    interval = 60
    timeout = 30
  }
}

resource "aws_lb_listener_rule" "akita" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 86

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.akita.arn
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.akita.name]
  }
}

resource "aws_route53_record" "akita" {
    zone_id = data.aws_route53_zone.production.zone_id
    name = "commons.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = ["cname.vercel-dns.com"]
}

// resource "aws_route53_record" "akita" {
//     zone_id = data.aws_route53_zone.production.zone_id
//     name = "commons.datacite.org"
//     type = "CNAME"
//     ttl = var.ttl
//     records = [data.aws_lb.default.dns_name]
// }

resource "aws_route53_record" "split-akita" {
    zone_id = data.aws_route53_zone.internal.zone_id
    name = "commons.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.default.dns_name]
}

resource "aws_service_discovery_service" "akita" {
  name = "akita"

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
