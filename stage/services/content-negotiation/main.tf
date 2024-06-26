resource "aws_ecs_service" "content-negotiation-stage" {
  name = "content-negotiation-stage"
  cluster = data.aws_ecs_cluster.stage.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.content-negotiation-stage.arn
  desired_count = 1

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.content-negotiation-stage.id
    container_name   = "content-negotiation-stage"
    container_port   = "80"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.content-negotiation-stage.arn
  }

  depends_on = [
    "data.aws_lb_listener.crosscite-stage",
  ]
}

resource "aws_cloudwatch_log_group" "content-negotiation-stage" {
  name = "/ecs/content-negotiation-stage"
}

resource "aws_ecs_task_definition" "content-negotiation-stage" {
  family = "content-negotiation-stage"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "2048"

  container_definitions =  data.template_file.content-negotiation_task.rendered
}

resource "aws_lb_listener_rule" "content-negotiation-stage" {
  listener_arn = data.aws_lb_listener.crosscite-stage.arn
  priority     = 61

  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.content-negotiation-stage.arn
  }

  condition {
    host_header {
      values = [aws_route53_record.content-negotiation-stage.name]
    }
  }
}

resource "aws_lb_listener_rule" "data-stage" {
  listener_arn = data.aws_lb_listener.stage.arn
  priority     = 60

  action {
    type = "redirect"

    redirect {
      host        = "data.test.crosscite.org"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }

  condition {
    host_header {
      values = [aws_route53_record.data-stage.name]
    }
  }
}

resource "aws_route53_record" "data-stage" {
    zone_id = data.aws_route53_zone.production.zone_id
    name = "data.stage.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.stage.dns_name]
}

resource "aws_route53_record" "content-negotiation-stage" {
    zone_id = data.aws_route53_zone.crosscite.zone_id
    name = "data.stage.crosscite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.crosscite-stage.dns_name]
}

resource "aws_route53_record" "data-test" {
    zone_id = data.aws_route53_zone.production.zone_id
    name = "data.test.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.test.dns_name]
}

resource "aws_service_discovery_service" "content-negotiation-stage" {
  name = "content-negotiation.stage"

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
