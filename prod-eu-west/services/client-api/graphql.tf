resource "aws_ecs_service" "graphql" {
  name            = "graphql"
  cluster         = data.aws_ecs_cluster.default.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.graphql.arn

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
    target_group_arn = aws_lb_target_group.graphql.id
    container_name   = "graphql"
    container_port   = "80"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.graphql.arn
  }

  depends_on = [
    data.aws_lb_listener.default,
  ]
}

resource "aws_appautoscaling_target" "graphql" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/default/${aws_ecs_service.graphql.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "graphql_scale_up" {
  name               = "scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.graphql.resource_id
  scalable_dimension = aws_appautoscaling_target.graphql.scalable_dimension
  service_namespace  = aws_appautoscaling_target.graphql.service_namespace

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

resource "aws_appautoscaling_policy" "graphql_scale_down" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.graphql.resource_id
  scalable_dimension = aws_appautoscaling_target.graphql.scalable_dimension
  service_namespace  = aws_appautoscaling_target.graphql.service_namespace

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

resource "aws_cloudwatch_metric_alarm" "graphql_request_scale_up" {
  alarm_name          = "graphql_request_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "180"

  dimensions = {
    TargetGroup = aws_lb_target_group.graphql.arn_suffix
  }

  alarm_description = "This metric monitors request counts"
  alarm_actions     = [aws_appautoscaling_policy.graphql_scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "graphql_request_scale_down" {
  alarm_name          = "graphql_request_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "150"

  dimensions = {
    TargetGroup = aws_lb_target_group.graphql.arn_suffix
  }

  alarm_description = "This metric monitors request counts"
  alarm_actions     = [aws_appautoscaling_policy.graphql_scale_down.arn]
}

resource "aws_cloudwatch_log_group" "graphql" {
  name = "/ecs/graphql"
}

resource "aws_ecs_task_definition" "graphql" {
  family                   = "graphql"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "4096"
  memory                   = "10240"
  container_definitions = templatefile("graphql.json",
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
  })
}

resource "aws_lb_target_group" "graphql" {
  name        = "graphql"
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

resource "aws_lb_listener_rule" "api-graphql" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 39

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.graphql.arn
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

resource "aws_service_discovery_service" "graphql" {
  name = "graphql"

  health_check_custom_config {
    failure_threshold = 2
  }

  dns_config {
    namespace_id = var.namespace_id

    dns_records {
      ttl  = 300
      type = "A"
    }
  }
}
