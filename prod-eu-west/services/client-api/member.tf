resource "aws_ecs_service" "member-api" {
  name            = "member-api"
  cluster         = data.aws_ecs_cluster.default.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.member-api.arn

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
    target_group_arn = aws_lb_target_group.member-api.id
    container_name   = "member-api"
    container_port   = "80"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.member-api.arn
  }

  depends_on = [
    data.aws_lb_listener.default,
  ]
}

resource "aws_appautoscaling_target" "member-api" {
  max_capacity       = 16
  min_capacity       = 2
  resource_id        = "service/default/${aws_ecs_service.member-api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# New Scaling Configuration
## Scaling Alarms SNS Topic
resource "aws_sns_topic" "member-api-scaling-alarms" {
  name = "member-api-scaling-alarms"
}

## Scaling Policy Actions
### Worker Utilisation
resource "aws_appautoscaling_policy" "member-api-worker_util_scale_up" {
  name               = "member-api-worker-util-scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.member-api.resource_id
  scalable_dimension = aws_appautoscaling_target.member-api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.member-api.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "member-api-worker_util_scale_down" {
  name               = "member-api-worker-util-scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.member-api.resource_id
  scalable_dimension = aws_appautoscaling_target.member-api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.member-api.service_namespace

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

### Queue Size
resource "aws_appautoscaling_policy" "member-api-emergency_scale_up" {
  name               = "member-api-queue-size-scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.member-api.resource_id
  scalable_dimension = aws_appautoscaling_target.member-api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.member-api.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 2
    }
  }
}

### P95 Response Time
resource "aws_appautoscaling_policy" "member-api-response_time_scale_up" {
  name               = "member-api-response-time-scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.member-api.resource_id
  scalable_dimension = aws_appautoscaling_target.member-api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.member-api.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 900
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

## CloudWatch Metrics Alarms
### Worker utilisation
resource "aws_cloudwatch_metric_alarm" "member-api-worker_util_scale_up" {
  alarm_name          = "member-api-worker-utilisation-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "PassengerWorkerUtilisation"
  namespace           = "Custom/LupoPassenger"
  period              = "60"
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    Service = "member-api"
  }

  alarm_description = "Scale up member-api when average worker utilisation is high"
  alarm_actions     = [
    aws_appautoscaling_policy.member-api-worker_util_scale_up.arn,
    aws_sns_topic.member-api-scaling-alarms.arn
  ]
  ok_actions = [aws_sns_topic.member-api-scaling-alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "member-api-worker_util_scale_down" {
  alarm_name          = "member-api-worker-utilisation-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "PassengerWorkerUtilisation"
  namespace           = "Custom/LupoPassenger"
  period              = "300"
  statistic           = "Maximum"
  threshold           = 35

  dimensions = {
    Service = "member-api"
  }

  alarm_description = "Scale down member-api when max worker utilisation has lowered"
  alarm_actions     = [
    aws_appautoscaling_policy.member-api-worker_util_scale_down.arn #,
    # Temporarily disabled to lower noise in #ops
    #aws_sns_topic.member-api-scaling-alarms.arn
  ]
  # Temporarily disabled to lower noise in #ops
  #ok_actions = [aws_sns_topic.member-api-scaling-alarms.arn]
}

## Queue Size
resource "aws_cloudwatch_metric_alarm" "member-api-queue_size_scale_up" {
  alarm_name          = "member-api-queue-size-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "PassengerRequestQueue"
  namespace           = "Custom/LupoPassenger"
  period              = "60"
  statistic           = "Maximum"
  threshold           = 1

  dimensions = {
    Service = "member-api"
  }

  alarm_description = "Emergency scale up: requests are queuing in member-api"
  alarm_actions     = [
    aws_appautoscaling_policy.member-api-emergency_scale_up.arn,
    aws_sns_topic.member-api-scaling-alarms.arn
  ]
  ok_actions = [aws_sns_topic.member-api-scaling-alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "member-api-response_time_scale_up" {
  alarm_name          = "member-api-response-time-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  # 3s response time because this is an emergency alarm, so it's preferable to avoid excess scaling events until we
  # can improve the response speed of the slower endpoints, or find a way to exclude them from the metrics
  threshold           = 3

  metric_query {
    id          = "target_response_time"
    return_data = true

    metric {
      metric_name = "TargetResponseTime"
      namespace   = "AWS/ApplicationELB"
      period      = "120"
      stat        = "p95"

      dimensions = {
        TargetGroup = aws_lb_target_group.member-api.arn_suffix
        LoadBalancer = data.aws_lb.default.arn_suffix
      }
    }
  }
  treat_missing_data = "notBreaching"

  alarm_description = "Safety net: scale up member-api when P95 response time exceeds 750ms"
  alarm_actions     = [
    aws_appautoscaling_policy.member-api-response_time_scale_up.arn,
    aws_sns_topic.member-api-scaling-alarms.arn
  ]
  ok_actions = [aws_sns_topic.member-api-scaling-alarms.arn]
}

resource "aws_cloudwatch_log_group" "member-api" {
  name = "/ecs/member-api"
}

resource "aws_ecs_task_definition" "member-api" {
  family                   = "member-api"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "4096"
  memory                   = "10240"
  container_definitions = templatefile("member-api.json",
    {
      re3data_url                       = var.re3data_url
      api_url                           = var.api_url
      bracco_url                        = var.bracco_url
      jwt_public_key                    = var.jwt_public_key
      jwt_private_key                   = var.jwt_private_key
      session_encrypted_cookie_salt     = var.session_encrypted_cookie_salt
      handle_url                        = var.handle_url
      handle_username                   = var.handle_username
      handle_password                   = var.handle_password
      mysql_user                        = var.mysql_user
      mysql_password                    = var.mysql_password
      mysql_database                    = var.mysql_database
      mysql_host                        = var.mysql_host
      es_name                           = var.es_name
      es_host                           = var.es_host
      public_key                        = var.public_key
      access_key                        = var.api_aws_access_key
      secret_key                        = var.api_aws_secret_key
      region                            = var.region
      s3_bucket                         = var.s3_bucket
      admin_username                    = var.admin_username
      admin_password                    = var.admin_password
      sentry_dsn                        = var.sentry_dsn
      mailgun_api_key                   = var.mailgun_api_key
      memcache_servers                  = var.memcache_servers
      slack_webhook_url                 = var.slack_webhook_url
      jwt_blacklisted                   = var.jwt_blacklisted
      version                           = var.lupo_tags["version"]
      exclude_prefixes_from_data_import = var.exclude_prefixes_from_data_import
      metadata_storage_bucket_name      = var.metadata_storage_bucket_name
      passenger_max_pool_size           = var.passenger_max_pool_size
      passenger_min_instances           = var.passenger_min_instances
      monthly_datafile_bucket           = var.monthly_datafile_bucket
      monthly_datafile_access_role      = var.monthly_datafile_access_role
      disable_facets_by_default         = var.disable_facets_by_default
      ror_analysis_s3_bucket            = var.ror_analysis_s3_bucket
  })
}

resource "aws_lb_target_group" "member-api" {
  name        = "member-api"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path     = "/heartbeat"
    timeout  = 30
    interval = 60
  }
}

resource "aws_lb_listener_rule" "member-api" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 41

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.member-api.arn
  }

  condition {
    host_header {
      values = [var.api_dns_name]
    }
  }

  condition {
    http_header {
      http_header_name = "Authorization"
      values           = ["Basic*", "Bearer*"]
    }
  }
}

resource "aws_service_discovery_service" "member-api" {
  name = "member-api"

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
