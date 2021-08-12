resource "aws_ecs_service" "analytics-hosting-stage" {
  name = "analytics-hosting-stage"
  cluster = data.aws_ecs_cluster.stage.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.analytics-hosting-stage.arn
  desired_count = 0

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.analytics-hosting-stage.id
    container_name   = "analytics-hosting-stage"
    container_port   = "80"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.analytics-hosting-stage.arn
  }

  depends_on = [
    data.aws_lb_listener.stage
  ]
}

resource "aws_cloudwatch_log_group" "analytics-hosting-stage" {
  name = "/ecs/analytics-hosting-stage"
}

resource "aws_ecs_task_definition" "analytics-hosting-stage" {
  family = "analytics-hosting-stage"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "2048"
  memory = "4096"

  container_definitions =  data.template_file.analytics-hosting_task.rendered
}

resource "aws_lb_target_group" "analytics-hosting-stage" {
  name     = "analytics-hosting-stage"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path = "/"
    interval = 300
    timeout = 120
  }
}

resource "aws_lb_listener_rule" "analytics-hosting-stage" {
  listener_arn = data.aws_lb_listener.stage.arn
  # priority     = 90

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.analytics-hosting-stage.arn
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.analytics-hosting-stage.name]
  }
}

resource "aws_route53_record" "analytics-hosting-stage" {
    zone_id = data.aws_route53_zone.production.zone_id
    name = "analytics-hosting.stage.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.stage.dns_name]
}

resource "aws_service_discovery_service" "analytics-hosting-stage" {
  name = "analytics-hosting.stage"

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
