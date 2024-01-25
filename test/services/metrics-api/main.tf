resource "aws_s3_bucket" "metrics" {
    bucket = var.s3_bucket
    acl = "public-read"
    policy = data.template_file.metrics-api_s3.rendered
    tags = {
        Name = "metricsApiTest"
    }
}

resource "aws_ecs_service" "metrics-api-test" {
  name            = "metrics-api-test"
  cluster         = data.aws_ecs_cluster.test.id
  task_definition = aws_ecs_task_definition.metrics-api-test.arn
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
    target_group_arn = aws_lb_target_group.metrics-api-test.id
    container_name   = "metrics-api-test"
    container_port   = "80"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.metrics-api-test.arn
  }

   depends_on = [
     data.aws_lb_listener.test
  ]
}

resource "aws_lb_target_group" "metrics-api-test" {
  name     = "metrics-api-test"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.vpc_id

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_cloudwatch_log_group" "metrics-api-test" {
  name = "/ecs/metrics-api-test"
}

resource "aws_ecs_task_definition" "metrics-api-test" {
  family = "metrics-api-test"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "2048"
  container_definitions =  data.template_file.metrics-api_task.rendered
}

resource "aws_lb_listener_rule" "metrics-api-test" {
  listener_arn = data.aws_lb_listener.test.arn
  priority     = 29

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.metrics-api-test.arn
  }

  condition {
    host_header {
      values = ["api.test.datacite.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/reports*"]
    }
  }
}

resource "aws_lb_listener_rule" "metrics-api-test-subset" {
  listener_arn = data.aws_lb_listener.test.arn
  priority     = 28

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.metrics-api-test.arn
  }

  condition {
    host_header {
      values = ["api.test.datacite.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/report-subsets*"]
    }
  }
}

resource "aws_lb_listener_rule" "metrics-api-test-repositories" {
  listener_arn = data.aws_lb_listener.test.arn
  priority     = 31

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.metrics-api-test.arn
  }

  condition {
    host_header {
      values = ["api.test.datacite.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/repositories-usage-reports*"]
    }
  }
}

resource "aws_service_discovery_service" "metrics-api-test" {
  name = "metrics-api.test"

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
