resource "aws_ecs_service" "client-api-stage" {
  name            = "client-api-stage"
  cluster         = data.aws_ecs_cluster.stage.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.client-api-stage.arn
  desired_count   = 2

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.client-api-stage.id
    container_name   = "client-api-stage"
    container_port   = "80"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.client-api-stage.arn
  }

  depends_on = [
    data.aws_lb_listener.stage
  ]
}

resource "aws_cloudwatch_log_group" "client-api-stage" {
  name = "/ecs/client-api-stage"
}

resource "aws_ecs_task_definition" "client-api-stage" {
  family                   = "client-api-stage"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "4096"
  container_definitions = templatefile("client-api.json",
    {
      re3data_url                             = var.re3data_url
      bracco_url                              = var.bracco_url
      public_key                              = var.public_key
      jwt_public_key                          = var.jwt_public_key
      jwt_private_key                         = var.jwt_private_key
      session_encrypted_cookie_salt           = var.session_encrypted_cookie_salt
      mysql_user                              = var.mysql_user
      mysql_password                          = var.mysql_password
      mysql_database                          = var.mysql_database
      mysql_host                              = var.mysql_host
      es_name                                 = var.es_name
      es_host                                 = var.es_host
      es_scheme                               = var.es_scheme
      es_port                                 = var.es_port
      es_prefix                               = var.es_prefix
      elastic_password                        = var.elastic_password
      handle_url                              = var.handle_url
      handle_username                         = var.handle_username
      handle_password                         = var.handle_password
      admin_username                          = var.admin_username
      admin_password                          = var.admin_password
      access_key                              = var.api_aws_access_key
      secret_key                              = var.api_aws_secret_key
      region                                  = var.region
      s3_bucket                               = var.s3_bucket
      sentry_dsn                              = var.sentry_dsn
      mailgun_api_key                         = var.mailgun_api_key
      memcache_servers                        = var.memcache_servers
      jwt_blacklisted                         = var.jwt_blacklisted
      slack_webhook_url                       = var.slack_webhook_url
      version                                 = var.lupo_tags["version"]
      sha                                     = var.lupo_tags["sha"]
      exclude_prefixes_from_data_import       = var.exclude_prefixes_from_data_import
      metadata_storage_bucket_name            = var.metadata_storage_bucket_name
      passenger_max_pool_size                 = var.passenger_max_pool_size
      passenger_min_instances                 = var.passenger_min_instances
      monthly_datafile_bucket                 = var.monthly_datafile_bucket
      monthly_datafile_access_role            = var.monthly_datafile_access_role
      enrichments_ingestion_files_bucket_name = var.enrichments_ingestion_files_bucket_name
      disable_facets_by_default               = var.disable_facets_by_default
      ror_analysis_s3_bucket                  = var.ror_analysis_s3_bucket
  })
}

resource "aws_lb_target_group" "client-api-stage" {
  name        = "client-api-stage"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path     = "/heartbeat"
    interval = 300
    timeout  = 120
  }
}

resource "aws_lb_listener_rule" "api-graphql-stage" {
  listener_arn = data.aws_lb_listener.stage.arn
  priority     = 48

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.client-api-stage.arn
  }

  condition {
    host_header {
      values = [var.api_dns_name]
    }
  }

  condition {
    path_pattern {
      values = ["/client-api/graphql"]
    }
  }
}

resource "aws_lb_listener_rule" "api-stage" {
  listener_arn = data.aws_lb_listener.stage.arn
  priority     = 54

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.client-api-stage.arn
  }

  condition {
    host_header {
      values = [var.api_dns_name]
    }
  }

}

resource "aws_service_discovery_service" "client-api-stage" {
  name = "client-api.stage"

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

resource "aws_route53_record" "api-stage" {
  zone_id = data.aws_route53_zone.production.zone_id
  name    = "api.stage.datacite.org"
  type    = "CNAME"
  ttl     = var.ttl
  records = [data.aws_lb.stage.dns_name]
}

resource "aws_route53_record" "split-api-stage" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "api.stage.datacite.org"
  type    = "CNAME"
  ttl     = var.ttl
  records = [data.aws_lb.stage.dns_name]
}

resource "aws_s3_bucket" "metadata" {
  bucket = "metadata-stage"
  tags = {
    Enviroment = "stage"
    Name       = "Metadata storage"
  }
}

# Scaling alarms SNS topic
resource "aws_sns_topic" "client-api-stage-scaling-alarms" {
  name = "client-api-stage-scaling-alarms"
}

# Scaling Policy Actions
## Autoscale Target
resource "aws_appautoscaling_target" "client-api-stage" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/stage/${aws_ecs_service.client-api-stage.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

## Worker Utilisation
resource "aws_appautoscaling_policy" "client-api-stage_scale_up" {
  name               = "client-api-stage-worker-util-scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.client-api-stage.resource_id
  scalable_dimension = aws_appautoscaling_target.client-api-stage.scalable_dimension
  service_namespace  = aws_appautoscaling_target.client-api-stage.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120 # TODO: Evaluate this during alarm testing
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "client-api-stage_scale_down" {
  name               = "client-api-stage-worker-util-scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.client-api-stage.resource_id
  scalable_dimension = aws_appautoscaling_target.client-api-stage.scalable_dimension
  service_namespace  = aws_appautoscaling_target.client-api-stage.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300 # TODO: Evaluate this during alarm testing
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

## Queue Size
resource "aws_appautoscaling_policy" "client-api-stage_emergency_scale_up" {
  name               = "client-api-stage-queue-size-scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.client-api-stage.resource_id
  scalable_dimension = aws_appautoscaling_target.client-api-stage.scalable_dimension
  service_namespace  = aws_appautoscaling_target.client-api-stage.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120 # TODO: Evaluate this during alarm testing
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 2
    }
  }
}

## P95 Response Time
resource "aws_appautoscaling_policy" "client-api-stage_response_time_scale_up" {
  name               = "client-api-stage-response-time-scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.client-api-stage.resource_id
  scalable_dimension = aws_appautoscaling_target.client-api-stage.scalable_dimension
  service_namespace  = aws_appautoscaling_target.client-api-stage.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300 # TODO: Evaluate this during alarm testing
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

# CloudWatch Metrics Alarms
## Worker utilisation
resource "aws_cloudwatch_metric_alarm" "client-api-stage_worker_util_scale_up" {
  alarm_name          = "client-api-stage-worker-utilisation-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3" # TODO: Evaluate this during alarm testing
  metric_name         = "PassengerWorkerUtilisation"
  namespace           = "Custom/LupoPassenger"
  period              = "60" # TODO: Evaluate this during alarm testing
  statistic           = "Average"
  threshold           = 75  # TODO: Update this number based on traffic analysis

  dimensions = {
    Service = "client-api.stage"
  }

  alarm_description = "Scale up client-api.stage when average worker utilisation is high"
  alarm_actions     = [
    #aws_appautoscaling_policy.client-api-stage_scale_up.arn,
    aws_sns_topic.client-api-stage-scaling-alarms.arn
  ]
  ok_actions = [aws_sns_topic.client-api-stage-scaling-alarms.arn]
  #actions_enabled   = false  # TODO: Remove this once alarms are verified
}

resource "aws_cloudwatch_metric_alarm" "client-api-stage_worker_util_scale_down" {
  alarm_name          = "client-api-stage-worker-utilisation-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3" # TODO: Evaluate this during alarm testing
  metric_name         = "PassengerWorkerUtilisation"
  namespace           = "Custom/LupoPassenger"
  period              = "300" # TODO: Evaluate this during alarm testing
  statistic           = "Maximum"
  threshold           = 35  # TODO: Update this number based on traffic analysis

  dimensions = {
    Service = "client-api.stage"
  }

  alarm_description = "Scale down client-api.stage when max worker utilisation has lowered"
  alarm_actions     = [
    #aws_appautoscaling_policy.client-api-stage_scale_down.arn,
    aws_sns_topic.client-api-stage-scaling-alarms.arn
  ]
  ok_actions = [aws_sns_topic.client-api-stage-scaling-alarms.arn]
  #actions_enabled   = false # TODO: Remove this once alarms are verified
}

## Queue Size
resource "aws_cloudwatch_metric_alarm" "client-api-stage_queue_size_scale_up" {
  alarm_name          = "client-api-stage-queue-size-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2" # TODO: Evaluate this during alarm testing
  metric_name         = "PassengerRequestQueue"
  namespace           = "Custom/LupoPassenger"
  period              = "60" # TODO: Evaluate this during alarm testing
  statistic           = "Maximum"
  threshold           = 1

  dimensions = {
    Service = "client-api.stage"
  }

  alarm_description = "Emergency scale up: requests are queuing in client-api.stage"
  alarm_actions     = [
    #aws_appautoscaling_policy.client-api-stage_emergency_scale_up.arn,
    aws_sns_topic.client-api-stage-scaling-alarms.arn
  ]
  ok_actions = [aws_sns_topic.client-api-stage-scaling-alarms.arn]
  #actions_enabled = false # TODO: Remove this once alarms are verified
}

resource "aws_cloudwatch_metric_alarm" "client-api-stage_response_time_scale_up" {
  alarm_name          = "client-api-stage-response-time-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3" # TODO: Evaluate this during alarm testing
  threshold           = 1 # TODO: Update this number based on traffic analysis

  metric_query {
    id          = "target_response_time"
    return_data = true

    metric {
      metric_name = "TargetResponseTime"
      namespace   = "AWS/ApplicationELB"
      period      = "120" # TODO: Evaluate this during alarm testing
      stat        = "p95"

      dimensions = {
        TargetGroup = aws_lb_target_group.client-api-stage.arn_suffix
        LoadBalancer = data.aws_lb.stage.arn_suffix
      }
    }
  }

  alarm_description = "Safety net: scale up client-api when P95 response time exceeds 1s"
  alarm_actions     = [
    #aws_appautoscaling_policy.client-api-stage_response_time_scale_up.arn,
    aws_sns_topic.client-api-stage-scaling-alarms.arn
  ]
  ok_actions = [aws_sns_topic.client-api-stage-scaling-alarms.arn]
  #actions_enabled = false # TODO: Remove this once alarms are verified
}