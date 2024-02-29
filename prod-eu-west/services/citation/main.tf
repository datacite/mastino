resource "aws_ecs_service" "citation" {
  name = "citation"
  cluster = data.aws_ecs_cluster.default.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.citation.arn

  # Create service with 2 instances to start
  desired_count = 2

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = ["desired_count"]
  }

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.citation.id
    container_name   = "citation"
    container_port   = "80"
  }

  depends_on = [
    "data.aws_lb_listener.crosscite"
  ]
}

resource "aws_appautoscaling_target" "citation" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/default/${aws_ecs_service.citation.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "citation_scale_up" {
  name               = "scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.citation.resource_id
  scalable_dimension = aws_appautoscaling_target.citation.scalable_dimension
  service_namespace  = aws_appautoscaling_target.citation.service_namespace

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

resource "aws_appautoscaling_policy" "citation_scale_down" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.citation.resource_id
  scalable_dimension = aws_appautoscaling_target.citation.scalable_dimension
  service_namespace  = aws_appautoscaling_target.citation.service_namespace

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

resource "aws_cloudwatch_metric_alarm" "citation_memory_scale_up" {
  alarm_name          = "citation_memory_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    ClusterName = "default"
    ServiceName = aws_ecs_service.citation.name
  }

  alarm_description = "This metric monitors ecs memory utilization"
  alarm_actions     = [aws_appautoscaling_policy.citation_scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "citation_memory_scale_down" {
  alarm_name          = "citation_memory_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    ClusterName = "default"
    ServiceName = aws_ecs_service.citation.name
  }

  alarm_description = "This metric monitors ecs memory utilization"
  alarm_actions     = [aws_appautoscaling_policy.citation_scale_down.arn]
}

resource "aws_cloudwatch_log_group" "citation" {
  name = "/ecs/citation"
}

resource "aws_ecs_task_definition" "citation" {
  family = "citation"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"

  container_definitions =  data.template_file.citation_task.rendered
}

resource "aws_lb_target_group" "citation" {
  name     = "citation"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener_rule" "citation" {
  listener_arn = data.aws_lb_listener.crosscite.arn
  priority     = 70

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.citation.arn
  }

  condition {
    host_header {
      values = [aws_route53_record.citation.name]
    }
  }
}

resource "aws_route53_record" "crosscite-apex" {
  zone_id = data.aws_route53_zone.crosscite.zone_id
  name = "crosscite.org"
  type = "A"

  alias {
    name = data.aws_lb.crosscite.dns_name
    zone_id = data.aws_lb.crosscite.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "crosscite-www" {
    zone_id = data.aws_route53_zone.crosscite.zone_id
    name = "www.crosscite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.crosscite.dns_name]
}


resource "aws_route53_record" "citation" {
    zone_id = data.aws_route53_zone.crosscite.zone_id
    name = "citation.crosscite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.crosscite.dns_name]
}
