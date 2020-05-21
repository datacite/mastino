resource "aws_ecs_service" "cheetoh-test" {
  name = "cheetoh-test"
  cluster = data.aws_ecs_cluster.test.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.cheetoh-test.arn
  desired_count = 1

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.cheetoh-test.id
    container_name   = "cheetoh-test"
    container_port   = "80"
  }

  depends_on = [
    "data.aws_lb_listener.test"
  ]
}

resource "aws_cloudwatch_log_group" "cheetoh-test" {
  name = "/ecs/cheetoh-test"
}

resource "aws_ecs_task_definition" "cheetoh-test" {
  family = "cheetoh-test"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "1024"
  container_definitions = templatefile("cheetoh.json",
    {
      secret_key_base    = var.secret_key_base
      sentry_dsn         = var.sentry_dsn
      memcache_servers   = var.memcache_servers
      api_url            = var.api_url
      admin_username     = var.admin_username
      admin_password     = var.admin_password
      version            = var.cheetoh_tags["sha"]
    })
}

resource "aws_lb_target_group" "cheetoh-test" {
  name     = "cheetoh-test"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "cheetoh-test" {
  listener_arn = data.aws_lb_listener.test.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cheetoh-test.arn
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.cheetoh-test.name]
  }
}

resource "aws_route53_record" "cheetoh-test" {
    zone_id = data.aws_route53_zone.production.zone_id
    name = "ez1.test.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.test.dns_name]
}

resource "aws_route53_record" "split-cheetoh-test" {
    zone_id = data.aws_route53_zone.internal.zone_id
    name = "ez1.test.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.test.dns_name]
}
