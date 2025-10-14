resource "aws_ecs_service" "queue-worker" {
  name            = "queue-worker"
  cluster         = data.aws_ecs_cluster.default.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.queue-worker.arn
  desired_count   = 1

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

  service_registries {
    registry_arn = aws_service_discovery_service.queue-worker.arn
  }

}

resource "aws_cloudwatch_log_group" "queue-worker" {
  name = "/ecs/queue-worker"
}

resource "aws_ecs_task_definition" "queue-worker" {
  family                   = "queue-worker"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "8192"
  container_definitions = templatefile("queue-worker.json",
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
      shoryuken_concurrency             = var.shoryuken_concurrency
      metadata_storage_bucket_name      = var.metadata_storage_bucket_name
      passenger_max_pool_size           = var.passenger_max_pool_size
      passenger_min_instances           = var.passenger_min_instances
  })
}

resource "aws_service_discovery_service" "queue-worker" {
  name = "queue-worker"

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


// Autoscaling target for queue-worker service
resource "aws_appautoscaling_target" "queue-worker" {
  max_capacity       = 40
  min_capacity       = 1
  resource_id        = "service/default/${aws_ecs_service.queue-worker.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "queue-worker_scale_up" {
  name               = "scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.queue-worker.resource_id
  scalable_dimension = aws_appautoscaling_target.queue-worker.scalable_dimension
  service_namespace  = aws_appautoscaling_target.queue-worker.service_namespace

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

resource "aws_appautoscaling_policy" "queue-worker_scale_down" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.queue-worker.resource_id
  scalable_dimension = aws_appautoscaling_target.queue-worker.scalable_dimension
  service_namespace  = aws_appautoscaling_target.queue-worker.service_namespace

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

// Cloudwatch metric alarm for scaling up based on SQS queue size
resource "aws_cloudwatch_metric_alarm" "queue_worker_scale_up_alarm" {
  alarm_name          = "queue_worker_scale_up_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  alarm_description   = "This metric monitors queue-worker queue size"
  alarm_actions       = [aws_appautoscaling_policy.queue-worker_scale_up.arn]

  threshold = "10000"

  // Custom query that sums the two other metrics
  // This is the value that will be compared to the threshold
  metric_query {
    id          = "total_visible"
    expression  = "production_visible + production_background_visible + production_registration_visible + production_import_datacite_doi + production_import_other_doi"
    label       = "Total visible messages"
    return_data = "true"
  }

  metric_query {
    id = "production_import_datacite_doi"

    metric {
      metric_name = "ApproximateNumberOfMessagesVisible"
      namespace   = "AWS/SQS"
      period      = "120"
      stat        = "Maximum"

      dimensions = {
        QueueName = "production_lupo_import"
      }
    }
  }

  metric_query {
    id = "production_import_other_doi"

    metric {
      metric_name = "ApproximateNumberOfMessagesVisible"
      namespace   = "AWS/SQS"
      period      = "120"
      stat        = "Maximum"

      dimensions = {
        QueueName = "production_lupo_import_other_doi"
      }
    }
  }


  metric_query {
    id = "production_visible"

    metric {
      metric_name = "ApproximateNumberOfMessagesVisible"
      namespace   = "AWS/SQS"
      period      = "120"
      stat        = "Maximum"

      dimensions = {
        QueueName = "production_lupo"
      }
    }
  }

  metric_query {
    id = "production_background_visible"

    metric {
      metric_name = "ApproximateNumberOfMessagesVisible"
      namespace   = "AWS/SQS"
      period      = "120"
      stat        = "Maximum"

      dimensions = {
        QueueName = "production_lupo_background"
      }
    }
  }

  metric_query {
    id = "production_registration_visible"

    metric {
      metric_name = "ApproximateNumberOfMessagesVisible"
      namespace   = "AWS/SQS"
      period      = "120"
      stat        = "Maximum"

      dimensions = {
        QueueName = "production_lupo_doi_registration"
      }
    }
  }

}

// Cloudwatch metric alarm for scaling down based on SQS queue size
resource "aws_cloudwatch_metric_alarm" "queue_worker_scale_down_alarm" {
  alarm_name          = "queue_worker_scale_down_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  // Evalulation period should be greater than the scale-up evalulation period
  // scale up quickly but scale down slowly to avoid potential thrashing of up/down periods
  evaluation_periods = "2"
  alarm_description  = "This metric monitors queue-worker queue size"
  alarm_actions      = [aws_appautoscaling_policy.queue-worker_scale_down.arn]

  threshold = "5000"

  // Custom query that sums the two other metrics
  metric_query {
    id          = "total_visible"
    expression  = "production_visible + production_background_visible + production_registration_visible + production_import_datacite_doi + production_import_other_doi"
    label       = "Total visible messages"
    return_data = "true"
  }

  metric_query {
    id = "production_import_datacite_doi"

    metric {
      metric_name = "ApproximateNumberOfMessagesVisible"
      namespace   = "AWS/SQS"
      period      = "120"
      stat        = "Maximum"

      dimensions = {
        QueueName = "production_lupo_import"
      }
    }
  }

  metric_query {
    id = "production_import_other_doi"

    metric {
      metric_name = "ApproximateNumberOfMessagesVisible"
      namespace   = "AWS/SQS"
      period      = "120"
      stat        = "Maximum"

      dimensions = {
        QueueName = "production_lupo_import_other_doi"
      }
    }
  }

  metric_query {
    id = "production_visible"

    metric {
      metric_name = "ApproximateNumberOfMessagesVisible"
      namespace   = "AWS/SQS"
      period      = "120"
      stat        = "Maximum"

      dimensions = {
        QueueName = "production_lupo"
      }
    }
  }

  metric_query {
    id = "production_background_visible"

    metric {
      metric_name = "ApproximateNumberOfMessagesVisible"
      namespace   = "AWS/SQS"
      period      = "120"
      stat        = "Maximum"

      dimensions = {
        QueueName = "production_lupo_background"
      }
    }
  }

  metric_query {
    id = "production_registration_visible"

    metric {
      metric_name = "ApproximateNumberOfMessagesVisible"
      namespace   = "AWS/SQS"
      period      = "120"
      stat        = "Maximum"

      dimensions = {
        QueueName = "production_lupo_doi_registration"
      }
    }
  }

}
