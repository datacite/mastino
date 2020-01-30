resource "aws_s3_bucket" "search" {
    bucket = "search.datacite.org"
    acl = "public-read"
    policy = "${data.template_file.search.rendered}"
    website {
        index_document = "index.html"
    }
    tags {
        Name = "Search"
    }
}

resource "aws_ecs_service" "search-crawler" {
  name = "search-crawler"
  cluster = "${data.aws_ecs_cluster.default.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.search.arn}"

  # Create service with 4 instances to start
  desired_count = 3

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = ["desired_count"]
  }

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.search-crawler.id}"
    container_name   = "search-crawler"
    container_port   = "80"
  }

  depends_on = [
    "data.aws_lb_listener.default",
  ]
}

resource "aws_appautoscaling_target" "search-crawler" {
  max_capacity       = 8
  min_capacity       = 3
  resource_id        = "service/default/${aws_ecs_service.search-crawler.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "search_scale_up" {
  name               = "scale-up"
  policy_type        = "StepScaling"
  resource_id        = "${aws_appautoscaling_target.search-crawler.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.search-crawler.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.search-crawler.service_namespace}"

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

resource "aws_appautoscaling_policy" "search-crawler_scale_down" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = "${aws_appautoscaling_target.search-crawler.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.search-crawler.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.search-crawler.service_namespace}"

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

resource "aws_cloudwatch_metric_alarm" "search-crawler_request_scale_up" {
  alarm_name          = "search-crawler_request_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "100"

  dimensions {
    TargetGroup  = "${aws_lb_target_group.search-crawler.arn_suffix}"
  }

  alarm_description = "This metric monitors request counts"
  alarm_actions     = ["${aws_appautoscaling_policy.search-crawler_scale_up.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "search-crawler_request_scale_down" {
  alarm_name          = "search-crawler_request_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "25"

  dimensions {
    TargetGroup  = "${aws_lb_target_group.search-crawler.arn_suffix}"
  }

  alarm_description = "This metric monitors request counts"
  alarm_actions     = ["${aws_appautoscaling_policy.search-crawler_scale_down.arn}"]
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

resource "aws_lb_target_group" "search-crawler" {
  name     = "search-crawler"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
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

resource "aws_cloudwatch_log_group" "search-crawler" {
  name = "/ecs/search-crawler"
}

resource "aws_ecs_task_definition" "search-crawler" {
  family = "search-crawler"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}",
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "1024"
  memory = "2048"

  container_definitions =  "${data.template_file.search-crawler_task.rendered}"
}

resource "aws_lb_listener_rule" "search-crawler" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 89

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.search-crawler.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.search.name}"]
  }
}
