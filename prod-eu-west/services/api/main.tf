resource "aws_ecs_service" "api" {
  name = "api"
  cluster = "${data.aws_ecs_cluster.default.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.api.arn}"

  # Create service with 2 instances to start
  desired_count = 0

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
    target_group_arn = "${aws_lb_target_group.api.id}"
    container_name   = "api"
    container_port   = "80"
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.api.arn}"
  }

  depends_on = [
    "data.aws_lb_listener.default",
  ]
}

resource "aws_appautoscaling_target" "api" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "service/default/${aws_ecs_service.api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "api_scale_up" {
  name               = "scale-up"
  policy_type        = "StepScaling"
  resource_id        = "${aws_appautoscaling_target.api.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.api.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.api.service_namespace}"

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

resource "aws_appautoscaling_policy" "api_scale_down" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = "${aws_appautoscaling_target.api.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.api.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.api.service_namespace}"

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

resource "aws_cloudwatch_metric_alarm" "api_cpu_scale_up" {
  alarm_name          = "api_cpu_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions {
    ClusterName = "default"
    ServiceName = "${aws_ecs_service.api.name}"
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions     = ["${aws_appautoscaling_policy.api_scale_up.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "api_cpu_scale_down" {
  alarm_name          = "api_cpu_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions {
    ClusterName = "default"
    ServiceName = "${aws_ecs_service.api.name}"
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions     = ["${aws_appautoscaling_policy.api_scale_down.arn}"]
}

resource "aws_cloudwatch_log_group" "api" {
  name = "/ecs/api"
}

resource "aws_ecs_task_definition" "api" {
  family = "api"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"

  container_definitions =  "${data.template_file.api_task.rendered}"
}

// resource "aws_lb_target_group" "api" {
//   name     = "api"
//   port     = 80
//   protocol = "HTTP"
//   vpc_id   = "${var.vpc_id}"
//   target_type = "ip"

//   health_check {
//     path = "/heartbeat"
//   }
// }

// resource "aws_lb_listener_rule" "api-works" {
//   listener_arn = "${data.aws_lb_listener.default.arn}"
//   priority     = 21

//   action {
//     type             = "forward"
//     target_group_arn = "${aws_lb_target_group.api.arn}"
//   }

//   condition {
//     field  = "host-header"
//     values = ["${aws_route53_record.api.name}"]
//   }
//   condition {
//     field  = "path-pattern"
//     values = ["/works*"]
//   }
// }

// resource "aws_lb_listener_rule" "api-pages" {
//   listener_arn = "${data.aws_lb_listener.default.arn}"
//   priority     = 21

//   action {
//     type             = "forward"
//     target_group_arn = "${aws_lb_target_group.api.arn}"
//   }

//   condition {
//     field  = "host-header"
//     values = ["${aws_route53_record.api.name}"]
//   }
//   condition {
//     field  = "path-pattern"
//     values = ["/pages*"]
//   }
// }

// resource "aws_lb_listener_rule" "api-graphql" {
//   listener_arn = "${data.aws_lb_listener.default.arn}"
//   priority     = 22

//   action {
//     type             = "forward"
//     target_group_arn = "${aws_lb_target_group.api.arn}"
//   }

//   condition {
//     field  = "host-header"
//     values = ["${aws_route53_record.api.name}"]
//   }
//   condition {
//     field  = "path-pattern"
//     values = ["/api/graphql"]
//   }
// }

// resource "aws_lb_listener_rule" "api-milestones" {
//   listener_arn = "${data.aws_lb_listener.default.arn}"
//   priority     = 23

//   action {
//     type             = "forward"
//     target_group_arn = "${aws_lb_target_group.api.arn}"
//   }

//   condition {
//     field  = "host-header"
//     values = ["${aws_route53_record.api.name}"]
//   }
//   condition {
//     field  = "path-pattern"
//     values = ["/milestones*"]
//   }
// }

// resource "aws_lb_listener_rule" "api-user-stories" {
//   listener_arn = "${data.aws_lb_listener.default.arn}"
//   priority     = 24

//   action {
//     type             = "forward"
//     target_group_arn = "${aws_lb_target_group.api.arn}"
//   }

//   condition {
//     field  = "host-header"
//     values = ["${aws_route53_record.api.name}"]
//   }
//   condition {
//     field  = "path-pattern"
//     values = ["/user-stories*"]
//   }
// }

// resource "aws_lb_listener_rule" "api-datasets" {
//   listener_arn = "${data.aws_lb_listener.default.arn}"
//   priority     = 25

//   action {
//     type             = "forward"
//     target_group_arn = "${aws_lb_target_group.api.arn}"
//   }

//   condition {
//     field  = "host-header"
//     values = ["${aws_route53_record.api.name}"]
//   }
//   condition {
//     field  = "path-pattern"
//     values = ["/datasets*"]
//   }
// }

// resource "aws_lb_listener_rule" "api-data-centers" {
//   listener_arn = "${data.aws_lb_listener.default.arn}"
//   priority     = 26

//   action {
//     type             = "forward"
//     target_group_arn = "${aws_lb_target_group.api.arn}"
//   }

//   condition {
//     field  = "host-header"
//     values = ["${aws_route53_record.api.name}"]
//   }
//   condition {
//     field  = "path-pattern"
//     values = ["/data-centers*"]
//   }
// }

// resource "aws_lb_listener_rule" "api-members" {
//   listener_arn = "${data.aws_lb_listener.default.arn}"
//   priority     = 27

//   action {
//     type             = "forward"
//     target_group_arn = "${aws_lb_target_group.api.arn}"
//   }

//   condition {
//     field  = "host-header"
//     values = ["${aws_route53_record.api.name}"]
//   }
//   condition {
//     field  = "path-pattern"
//     values = ["/members*"]
//   }
// }

resource "aws_route53_record" "api" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "api.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.default.dns_name}"]
}

resource "aws_route53_record" "split-api" {
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "api.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.default.dns_name}"]
}

resource "aws_service_discovery_service" "api" {
  name = "api"

  health_check_custom_config {
    failure_threshold = 3
  }

  dns_config {
    namespace_id = "${var.namespace_id}"
    
    dns_records {
      ttl = 300
      type = "A"
    }
  }
}