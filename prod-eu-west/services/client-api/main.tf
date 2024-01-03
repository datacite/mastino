resource "aws_ecs_service" "client-api" {
  name = "client-api"
  cluster = data.aws_ecs_cluster.default.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.client-api.arn

  desired_count = 4

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
    target_group_arn = aws_lb_target_group.client-api.id
    container_name   = "client-api"
    container_port   = "80"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.client-api.arn
  }

  depends_on = [
    "data.aws_lb_listener.default",
  ]
}

resource "aws_appautoscaling_target" "client-api" {
  max_capacity       = 16
  min_capacity       = 12
  resource_id        = "service/default/${aws_ecs_service.client-api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "client-api_scale_up" {
  name               = "scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.client-api.resource_id
  scalable_dimension = aws_appautoscaling_target.client-api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.client-api.service_namespace

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

resource "aws_appautoscaling_policy" "client-api_scale_down" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.client-api.resource_id
  scalable_dimension = aws_appautoscaling_target.client-api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.client-api.service_namespace

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

resource "aws_cloudwatch_metric_alarm" "client-api_request_scale_up" {
  alarm_name          = "client-api_request_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "180"

  dimensions = {
    TargetGroup  = aws_lb_target_group.client-api.arn_suffix
  }

  alarm_description = "This metric monitors request counts"
  alarm_actions     = ["${aws_appautoscaling_policy.client-api_scale_up.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "client-api_request_scale_down" {
  alarm_name          = "client-api_request_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "150"

  dimensions = {
    TargetGroup  = aws_lb_target_group.client-api.arn_suffix
  }

  alarm_description = "This metric monitors request counts"
  alarm_actions     = [aws_appautoscaling_policy.client-api_scale_down.arn]
}

/* resource "aws_cloudwatch_metric_alarm" "client-api_cpu_scale_up" {
  alarm_name          = "client-api_cpu_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    ClusterName = "default"
    ServiceName = aws_ecs_service.client-api.name
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions     = [aws_appautoscaling_policy.client-api_scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "client-api_cpu_scale_down" {
  alarm_name          = "client-api_cpu_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    ClusterName = "default"
    ServiceName = aws_ecs_service.client-api.name
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions     = [aws_appautoscaling_policy.client-api_scale_down.arn]
} */

// resource "aws_cloudwatch_metric_alarm" "client-api_memory_scale_up" {
//   alarm_name          = "client-api_memory_scale_up"
//   comparison_operator = "GreaterThanOrEqualToThreshold"
//   evaluation_periods  = "2"
//   metric_name         = "MemoryUtilization"
//   namespace           = "AWS/ECS"
//   period              = "120"
//   statistic           = "Average"
//   threshold           = "80"

//   dimensions = {
//     ClusterName = "default"
//     ServiceName = aws_ecs_service.client-api.name
//   }

//   alarm_description = "This metric monitors ecs memory utilization"
//   alarm_actions     = [aws_appautoscaling_policy.client-api_scale_up.arn]
// }

// resource "aws_cloudwatch_metric_alarm" "client-api_memory_scale_down" {
//   alarm_name          = "client-api_memory_scale_down"
//   comparison_operator = "LessThanOrEqualToThreshold"
//   evaluation_periods  = "2"
//   metric_name         = "MemoryUtilization"
//   namespace           = "AWS/ECS"
//   period              = "120"
//   statistic           = "Average"
//   threshold           = "20"

//   dimensions = {
//     ClusterName = "default"
//     ServiceName = aws_ecs_service.client-api.name
//   }

//   alarm_description = "This metric monitors ecs memory utilization"
//   alarm_actions     = [aws_appautoscaling_policy.client-api_scale_down.arn]
// }

resource "aws_cloudwatch_log_group" "client-api" {
  name = "/ecs/client-api"
}

resource "aws_ecs_task_definition" "client-api" {
  family = "client-api"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "4096"
  memory = "10240"
  container_definitions =  templatefile("client-api.json",
    {
      re3data_url        = var.re3data_url
      api_url            = var.api_url
      bracco_url         = var.bracco_url
      jwt_public_key     = var.jwt_public_key
      jwt_private_key    = var.jwt_private_key
      session_encrypted_cookie_salt = var.session_encrypted_cookie_salt
      handle_url         = var.handle_url
      handle_username    = var.handle_username
      handle_password    = var.handle_password
      mysql_user         = var.mysql_user
      mysql_password     = var.mysql_password
      mysql_database     = var.mysql_database
      mysql_host         = var.mysql_host
      es_name            = var.es_name
      es_host            = var.es_host
      public_key         = var.public_key
      access_key         = var.access_key
      secret_key         = var.secret_key
      region             = var.region
      s3_bucket          = var.s3_bucket
      admin_username     = var.admin_username
      admin_password     = var.admin_password
      sentry_dsn         = var.sentry_dsn
      mailgun_api_key    = var.mailgun_api_key
      memcache_servers   = var.memcache_servers
      slack_webhook_url  = var.slack_webhook_url
      jwt_blacklisted    = var.jwt_blacklisted
      version            = var.lupo_tags["version"]
      plugin_openapi_url  = var.plugin_openapi_url
      plugin_manifest_url = var.plugin_manifest_url
    })
}

resource "aws_lb_target_group" "client-api" {
  name     = "client-api"
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

// resource "aws_lb_listener_rule" "client-api" {
//   listener_arn = data.aws_lb_listener.default.arn
//   priority     = 20

//   action {
//     type             = "forward"
//     target_group_arn = aws_lb_target_group.client-api.arn
//   }

//   condition {
//     field  = "host-header"
//     values = [aws_route53_record.client-api.name]
//   }
// }

resource "aws_lb_listener_rule" "api-graphql" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 39

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.client-api.arn
  }

  condition {
    path_pattern {
      values = ["/client-api/graphql"]
    }
  }

  condition {
    host_header {
      values = [var.api_dns_name]
    }
  }
}

resource "aws_lb_listener_rule" "api" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 43

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.client-api.arn
  }

  condition {
    host_header {
      values = [var.api_dns_name]
    }
  }
}

// resource "aws_route53_record" "client-api" {
//     zone_id = data.aws_route53_zone.production.zone_id
//     name = "api.datacite.org"
//     type = "CNAME"
//     ttl = var.ttl
//     records = [data.aws_lb.default.dns_name]
// }

// resource "aws_route53_record" "split-client-api" {
//     zone_id = data.aws_route53_zone.internal.zone_id
//     name = "api.datacite.org"
//     type = "CNAME"
//     ttl = var.ttl
//     records = [data.aws_lb.default.dns_name]
// }

resource "aws_service_discovery_service" "client-api" {
  name = "client-api"

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
