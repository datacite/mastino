resource "aws_s3_bucket" "search" {
    bucket = "search.datacite.org"
    acl = "public-read"
    policy = templatefile("s3_public_read.json",
      {
        vpce_id = data.aws_vpc_endpoint.datacite.id
        bucket_name = aws_route53_record.search.name
      })
    website {
        index_document = "index.html"
    }
    tags = {
        Name = "Search"
    }
}

resource "aws_ecs_service" "search" {
  name = "search"
  cluster = data.aws_ecs_cluster.default.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.search.arn

  # Create service with 4 instances to start
  desired_count = 3

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = ["desired_count"]
  }

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.search.id
    container_name   = "search"
    container_port   = "80"
  }

  depends_on = [
    "data.aws_lb_listener.default",
  ]
}

resource "aws_appautoscaling_target" "search" {
  max_capacity       = 8
  min_capacity       = 3
  resource_id        = "service/default/${aws_ecs_service.search.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "search_scale_up" {
  name               = "scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.search.resource_id
  scalable_dimension = aws_appautoscaling_target.search.scalable_dimension
  service_namespace  = aws_appautoscaling_target.search.service_namespace

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

resource "aws_appautoscaling_policy" "search_scale_down" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.search.resource_id
  scalable_dimension = aws_appautoscaling_target.search.scalable_dimension
  service_namespace  = aws_appautoscaling_target.search.service_namespace

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

resource "aws_cloudwatch_metric_alarm" "search_request_scale_up" {
  alarm_name          = "search_request_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "100"

  dimensions = {
    TargetGroup  = aws_lb_target_group.search.arn_suffix
  }

  alarm_description = "This metric monitors request counts"
  alarm_actions     = [aws_appautoscaling_policy.search_scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "search_request_scale_down" {
  alarm_name          = "search_request_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "25"

  dimensions = {
    TargetGroup  = aws_lb_target_group.search.arn_suffix
  }

  alarm_description = "This metric monitors request counts"
  alarm_actions     = [aws_appautoscaling_policy.search_scale_down.arn]
}

// resource "aws_cloudwatch_metric_alarm" "search_cpu_scale_up" {
//  alarm_name          = "search_cpu_scale_up"
//  comparison_operator = "GreaterThanOrEqualToThreshold"
//  evaluation_periods  = "2"
//  metric_name         = "CPUUtilization"
//  namespace           = "AWS/ECS"
//  period              = "120"
//  statistic           = "Average"
//  threshold           = "80"

//  dimensions {
//    ClusterName = "default"
//    ServiceName = "${aws_ecs_service.search.name}"
//  }

//  alarm_description = "This metric monitors ecs cpu utilization"
//  alarm_actions     = ["${aws_appautoscaling_policy.search_scale_up.arn}"]
// }

// resource "aws_cloudwatch_metric_alarm" "search_cpu_scale_down" {
// alarm_name          = "search_cpu_scale_down"
// comparison_operator = "LessThanOrEqualToThreshold"
//  evaluation_periods  = "2"
//  metric_name         = "CPUUtilization"
//  namespace           = "AWS/ECS"
//  period              = "120"
//  statistic           = "Average"
//  threshold           = "20"

//  dimensions {
//    ClusterName = "default"
//    ServiceName = "${aws_ecs_service.search.name}"
//  }

//  alarm_description = "This metric monitors ecs cpu utilization"
//  alarm_actions     = ["${aws_appautoscaling_policy.search_scale_down.arn}"]
// }

// resource "aws_cloudwatch_metric_alarm" "search_memory_scale_up" {
//   alarm_name          = "search_memory_scale_up"
//   comparison_operator = "GreaterThanOrEqualToThreshold"
//   evaluation_periods  = "2"
//   metric_name         = "MemoryUtilization"
//   namespace           = "AWS/ECS"
//   period              = "120"
//   statistic           = "Average"
//   threshold           = "80"

//   dimensions {
//     ClusterName = "default"
//     ServiceName = "${aws_ecs_service.search.name}"
//   }

//   alarm_description = "This metric monitors ecs memory utilization"
//   alarm_actions     = ["${aws_appautoscaling_policy.search_scale_up.arn}"]
// }

// resource "aws_cloudwatch_metric_alarm" "search_memory_scale_down" {
//   alarm_name          = "search_memory_scale_down"
//   comparison_operator = "LessThanOrEqualToThreshold"
//   evaluation_periods  = "2"
//   metric_name         = "MemoryUtilization"
//   namespace           = "AWS/ECS"
//   period              = "120"
//   statistic           = "Average"
//   threshold           = "20"

//   dimensions {
//     ClusterName = "default"
//     ServiceName = "${aws_ecs_service.search.name}"
//   }

//   alarm_description = "This metric monitors ecs memory utilization"
//   alarm_actions     = ["${aws_appautoscaling_policy.search_scale_down.arn}"]
// }

resource "aws_lb_target_group" "search" {
  name     = "search"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/heartbeat"
    interval = 60
    timeout = 10
  }

  stickiness {
    type   = "lb_cookie"
  }
}

resource "aws_cloudwatch_log_group" "search" {
  name = "/ecs/search"
}

resource "aws_ecs_task_definition" "search" {
  family = "search"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "1024"
  memory = "2048"

  container_definitions =  templatefile("search.json",
    {
      jwt_public_key     = var.jwt_public_key
      orcid_update_uuid  = var.orcid_update_uuid
      orcid_update_url   = var.orcid_update_url
      orcid_update_token = var.orcid_update_token
      orcid_url          = var.orcid_url
      volpino_url        = var.volpino_url
      homepage_url       = var.homepage_url
      commons_url        = var.commons_url
      jwt_host           = var.jwt_host
      api_url            = var.api_url
      fabrica_url        = var.fabrica_url
      data_url           = var.data_url
      cdn_url            = var.cdn_url
      sitemaps_url       = var.sitemaps_url
      sitemaps_bucket_url = var.sitemaps_bucket_url
      secret_key_base    = var.secret_key_base
      memcache_servers   = var.memcache_servers
      sentry_dsn         = var.sentry_dsn
      gabba_cookie       = var.gabba_cookie
      gabba_url          = var.gabba_url
      version            = var.doi-metadata-search_tags["version"]
    })
}

resource "aws_lb_listener_rule" "search" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 89

  action {
    type             = "redirect"
    
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      host = "commons.datacite.org"
      path = "/"
      query = ""
    }  
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.search.name]
  }
}

resource "aws_route53_record" "search" {
   zone_id = data.aws_route53_zone.production.zone_id
   name = "search.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = [data.aws_lb.default.dns_name]
}

resource "aws_route53_record" "split-search" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "search.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = [data.aws_lb.default.dns_name]
}

resource "aws_lb_listener_rule" "user-agent" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 81

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "The user-agent was found."
      status_code  = "200"
    }
  }

  condition {
    http_header {
      http_header_name = "user-agent"
      values           = ["*Googlebot*", "curl*"]
    }
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.search.name]
  }

  condition {
    field  = "path-pattern"
    values = ["/user-agent*"]
  }
}

// Old solr search interfaces
resource "aws_lb_listener_rule" "solr-api" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 80

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "This resource is no longer available."
      status_code  = "410"
    }
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.search.name]
  }

  condition {
    field  = "path-pattern"
    values = ["/api*"]
  }
}

resource "aws_lb_listener_rule" "solr-ui" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 82

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "This resource is no longer available."
      status_code  = "410"
    }
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.search.name]
  }

  condition {
    field  = "path-pattern"
    values = ["/ui*"]
  }
}
