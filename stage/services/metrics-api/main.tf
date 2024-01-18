resource "aws_s3_bucket" "metrics" {
  bucket = var.s3_bucket
  acl = "public-read"
  policy = data.template_file.metrics-api_s3.rendered
  tags = {
      Name = "metricsApiStage"
  }
  versioning {
    enabled = true
  }
  lifecycle_rule {
    enabled = true

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = 60
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      days = 365
    }
  }
}

resource "aws_ecs_service" "metrics-api-stage" {
  name            = "metrics-api-stage"
  cluster         = data.aws_ecs_cluster.stage.id
  task_definition = aws_ecs_task_definition.metrics-api-stage.arn
  desired_count   = 1
  launch_type = "FARGATE"


  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }


  load_balancer {
    target_group_arn = aws_lb_target_group.metrics-api-stage.id
    container_name   = "metrics-api-stage"
    container_port   = "80"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.metrics-api-stage.arn
  }

   depends_on = [
     "data.aws_lb_listener.stage"
  ]
}

resource "aws_lb_target_group" "metrics-api-stage" {
  name     = "metrics-api-stage"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.vpc_id

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_cloudwatch_log_group" "metrics-api-stage" {
  name = "/ecs/metrics-api-stage"
}

resource "aws_lb_listener_rule" "metrics-api-stage" {
  listener_arn = data.aws_lb_listener.stage.arn
  priority     = 29

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.metrics-api-stage.arn
  }

  condition {
    host_header {
      values = ["api.stage.datacite.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/reports*"]
    }
  }

}

resource "aws_lb_listener_rule" "metrics-api-stage-subset" {
  listener_arn = data.aws_lb_listener.stage.arn
  priority     = 28

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.metrics-api-stage.arn
  }

  condition {
    host_header {
      values = ["api.stage.datacite.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/report-subsets*"]
    }
  }
}


resource "aws_lb_listener_rule" "metrics-api-stage-repositories" {
  listener_arn = data.aws_lb_listener.stage.arn
  priority     = 31

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.metrics-api-stage.arn
  }

  condition {
    host_header {
      values = ["api.stage.datacite.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/repositories-usage-reports*"]
    }
  }
}

resource "aws_ecs_task_definition" "metrics-api-stage" {
  family = "metrics-api-stage"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "2048"
  container_definitions =  data.template_file.metrics-api_task.rendered
}

resource "aws_route53_record" "metrics-api-stage" {
  zone_id = data.aws_route53_zone.production.zone_id
  name = "metrics.stage.datacite.org"
  type = "CNAME"
  ttl = var.ttl
  records = [data.aws_lb.stage.dns_name]
}

resource "aws_route53_record" "split-metrics-api-stage" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name = "metrics.stage.datacite.org"
  type = "CNAME"
  ttl = var.ttl
  records = [data.aws_lb.stage.dns_name]
}

resource "aws_service_discovery_service" "metrics-api-stage" {
  name = "metrics-api.stage"

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
