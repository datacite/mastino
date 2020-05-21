resource "aws_ecs_service" "client-api-test" {
  name = "client-api-test"
  cluster = data.aws_ecs_cluster.test.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.client-api-test.arn
  desired_count = 1

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.client-api-test.id
    container_name   = "client-api-test"
    container_port   = "80"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.client-api-test.arn
  }

  depends_on = [
    "${aws_lb_listener.test}"
  ]
}

resource "aws_cloudwatch_log_group" "client-api-test" {
  name = "/ecs/client-api-test"
}

resource "aws_ecs_task_definition" "client-api-test" {
  family = "client-api-test"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "2048"
  memory = "4096"
  container_definitions =  data.template_file.client-api_task.rendered
}

resource "aws_lb_listener" "test" {
  load_balancer_arn = data.aws_lb.test.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.test.arn

  default_action {
    target_group_arn = aws_lb_target_group.client-api-test.id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "client-api-test" {
  name     = "client-api-test"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "api-graphql-test" {
  listener_arn = aws_lb_listener.test.arn
  priority     = 48

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.client-api-test.arn
  }

  condition {
    field  = "host-header"
    values = [var.api_dns_name]
  }

  condition {
    field  = "path-pattern"
    values = ["/client-api/graphql"]
  }
}

resource "aws_lb_listener_rule" "api-test" {
  listener_arn = aws_lb_listener.test.arn
  priority     = 54

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.client-api-test.arn
  }

  condition {
    field  = "host-header"
    values = [var.api_dns_name]
  }
}

resource "aws_service_discovery_service" "client-api-test" {
  name = "client-api.test"

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
