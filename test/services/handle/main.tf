resource "aws_ecs_service" "handle-test" {
  name            = "handle-test"
  cluster         = data.aws_ecs_cluster.test.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.handle-test.arn
  desired_count   = 1

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.handle-test.id
    container_name   = "handle-test"
    container_port   = "8000"
  }

  depends_on = [
    data.aws_lb_listener.test
  ]
}

resource "aws_cloudwatch_log_group" "handle-test" {
  name = "/ecs/handle-test"
}

resource "aws_ecs_task_definition" "handle-test" {
  family                = "handle-test"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  container_definitions = data.template_file.handle_task.rendered
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "1024"
}

resource "aws_lb_target_group" "handle-test" {
  name     = "handle-test"
  vpc_id   = var.vpc_id
  port     = 8000
  protocol = "HTTPS"
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener_rule" "handle-test" {
  listener_arn = data.aws_lb_listener.test.arn
  priority     = 3

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.handle-test.arn
  }

  condition {
    host_header {
      values = [aws_route53_record.handle-test.name]
    }
  }
}

resource "aws_route53_record" "handle-test" {
   zone_id = data.aws_route53_zone.production.zone_id
   name = "handle.test.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [data.aws_lb.test.dns_name]
}

resource "aws_route53_record" "split-handle-test" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "handle.test.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [data.aws_lb.test.dns_name]
}
