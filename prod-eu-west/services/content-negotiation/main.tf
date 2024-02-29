resource "aws_ecs_service" "content-negotiation" {
  name = "content-negotiation"
  cluster = data.aws_ecs_cluster.default.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.content-negotiation.arn

  # Create service with 2 instances to start
  desired_count = 10

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
    target_group_arn = aws_lb_target_group.content-negotiation.id
    container_name   = "content-negotiation"
    container_port   = "80"
  }

  depends_on = [
    "data.aws_lb_listener.crosscite",
  ]
}

resource "aws_appautoscaling_target" "content-negotiation" {
  max_capacity       = 10
  min_capacity       = 4
  resource_id        = "service/default/${aws_ecs_service.content-negotiation.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "content-negotiation_scale_up" {
  name               = "scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.content-negotiation.resource_id
  scalable_dimension = aws_appautoscaling_target.content-negotiation.scalable_dimension
  service_namespace  = aws_appautoscaling_target.content-negotiation.service_namespace

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

resource "aws_appautoscaling_policy" "content-negotiation_scale_down" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.content-negotiation.resource_id
  scalable_dimension = aws_appautoscaling_target.content-negotiation.scalable_dimension
  service_namespace  = aws_appautoscaling_target.content-negotiation.service_namespace

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

resource "aws_cloudwatch_metric_alarm" "content-negotiation_cpu_scale_up" {
  alarm_name          = "content-negotiation_cpu_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    ClusterName = "default"
    ServiceName = aws_ecs_service.content-negotiation.name
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions     = [aws_appautoscaling_policy.content-negotiation_scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "content-negotiation_cpu_scale_down" {
  alarm_name          = "content-negotiation_cpu_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    ClusterName = "default"
    ServiceName = aws_ecs_service.content-negotiation.name
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions     = [aws_appautoscaling_policy.content-negotiation_scale_down.arn]
}

resource "aws_cloudwatch_log_group" "content-negotiation" {
  name = "/ecs/content-negotiation"
}

resource "aws_ecs_task_definition" "content-negotiation" {
  family = "content-negotiation"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "4096"

  container_definitions =  data.template_file.content-negotiation_task.rendered
}

resource "aws_lb_target_group" "content-negotiation" {
  name     = "content-negotiation"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold = "4"
    unhealthy_threshold = "10"
    path = "/heartbeat"
    interval = "180"
  }
}

resource "aws_lb_listener_rule" "content-negotiation" {
  listener_arn = data.aws_lb_listener.crosscite.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.content-negotiation.arn
  }

  condition {
    host_header {
      values = [aws_route53_record.content-negotiation.name]
    }
  }
}

resource "aws_lb_listener_rule" "data" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 60

  action {
    type = "redirect"

    redirect {
      host        = "data.crosscite.org"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }

  condition {
    host_header {
      values = [aws_route53_record.data.name]
    }
  }
}

resource "aws_route53_record" "data" {
    zone_id = data.aws_route53_zone.production.zone_id
    name = "data.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.default.dns_name]
}

resource "aws_route53_record" "content-negotiation" {
    zone_id = data.aws_route53_zone.crosscite.zone_id
    name = "data.crosscite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.crosscite.dns_name]
}

resource "aws_service_discovery_service" "content-negotiation" {
  name = "content-negotiation"

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
