resource "aws_ecs_service" "mds" {
  name = "mds"
  cluster = data.aws_ecs_cluster.default.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.mds.arn

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
    target_group_arn = aws_lb_target_group.mds.id
    container_name   = "mds"
    container_port   = "80"
  }

  depends_on = [
    data.aws_lb_listener.default
  ]
}

resource "aws_appautoscaling_target" "mds" {
  max_capacity       = 10
  min_capacity       = 8
  resource_id        = "service/default/${aws_ecs_service.mds.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "mds_scale_up" {
  name               = "scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.mds.resource_id
  scalable_dimension = aws_appautoscaling_target.mds.scalable_dimension
  service_namespace  = aws_appautoscaling_target.mds.service_namespace

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

resource "aws_appautoscaling_policy" "mds_scale_down" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.mds.resource_id
  scalable_dimension = aws_appautoscaling_target.mds.scalable_dimension
  service_namespace  = aws_appautoscaling_target.mds.service_namespace

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

resource "aws_cloudwatch_metric_alarm" "mds_cpu_scale_up" {
  alarm_name          = "mds_cpu_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    ClusterName = "default"
    ServiceName = aws_ecs_service.mds.name
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions     = [aws_appautoscaling_policy.mds_scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "mds_cpu_scale_down" {
  alarm_name          = "mds_cpu_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    ClusterName = "default"
    ServiceName = aws_ecs_service.mds.name
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions     = [aws_appautoscaling_policy.mds_scale_down.arn]
}

// resource "aws_cloudwatch_metric_alarm" "mds_memory_scale_up" {
//   alarm_name          = "mds_memory_scale_up"
//   comparison_operator = "GreaterThanOrEqualToThreshold"
//   evaluation_periods  = "2"
//   metric_name         = "MemoryUtilization"
//   namespace           = "AWS/ECS"
//   period              = "120"
//   statistic           = "Average"
//   threshold           = "80"

//   dimensions {
//     ClusterName = "default"
//     ServiceName = "${aws_ecs_service.mds.name}"
//   }

//   alarm_description = "This metric monitors ecs memory utilization"
//   alarm_actions     = ["${aws_appautoscaling_policy.mds_scale_up.arn}"]
// }

// resource "aws_cloudwatch_metric_alarm" "mds_memory_scale_down" {
//   alarm_name          = "mds_memory_scale_down"
//   comparison_operator = "LessThanOrEqualToThreshold"
//   evaluation_periods  = "2"
//   metric_name         = "MemoryUtilization"
//   namespace           = "AWS/ECS"
//   period              = "120"
//   statistic           = "Average"
//   threshold           = "20"

//   dimensions {
//     ClusterName = "default"
//     ServiceName = "${aws_ecs_service.mds.name}"
//   }

//   alarm_description = "This metric monitors ecs memory utilization"
//   alarm_actions     = ["${aws_appautoscaling_policy.mds_scale_down.arn}"]
// }

resource "aws_cloudwatch_log_group" "mds" {
  name = "/ecs/mds"
}

resource "aws_ecs_task_definition" "mds" {
  family = "mds"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"

  container_definitions =  data.template_file.mds_task.rendered
}

resource "aws_lb_target_group" "mds" {
  name     = "mds"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/heartbeat"
    timeout = 30
    interval = 60
  }
}

resource "aws_lb_listener_rule" "mds" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 6

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mds.arn
  }

  condition {
    host_header {
      values = ["mds.datacite.org"]
    }
  }
}

resource "aws_route53_record" "mds" {
   zone_id = data.aws_route53_zone.production.zone_id
   name = "mds.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [aws_globalaccelerator_accelerator.mds.dns_name]
}

resource "aws_route53_record" "split-mds" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "mds.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [data.aws_lb.default.dns_name]
}