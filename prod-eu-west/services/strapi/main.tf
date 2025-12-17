resource "aws_ecs_service" "strapi" {
  name             = "strapi"
  cluster          = data.aws_ecs_cluster.default.id
  launch_type      = "FARGATE"
  task_definition  = aws_ecs_task_definition.strapi.arn
  platform_version = "1.4.0"
  desired_count    = 1

  # give container time to start up
  health_check_grace_period_seconds = 900

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets = [
      data.aws_subnet.datacite-private.id
    ]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.strapi.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.strapi.id
    container_name   = "strapi"
    container_port   = "1337"
  }

  depends_on = [
    data.aws_lb_listener.default,
  ]
}

resource "aws_cloudwatch_log_group" "strapi" {
  name = "/ecs/strapi"
}

resource "aws_ecs_task_definition" "strapi" {
  family                   = "strapi"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "2048"
  container_definitions = templatefile("strapi.json",
    {
      mysql_user     = var.mysql_user,
      mysql_password = var.mysql_password,
      mysql_database = var.mysql_database,
      mysql_host     = var.mysql_host
      public_key     = var.public_key
      version        = var.vers
  })
  volume {
    name = "strapi-storage"

    efs_volume_configuration {
      file_system_id = data.aws_efs_file_system.default.id
      root_directory = "/strapi"
    }
  }
}

resource "aws_route53_record" "strapi" {
  zone_id = data.aws_route53_zone.production.zone_id
  name    = "cms.datacite.org"
  type    = "CNAME"
  ttl     = var.ttl
  records = [data.aws_lb.default.dns_name]
}

resource "aws_route53_record" "split-strapi" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "cms.datacite.org"
  type    = "CNAME"
  ttl     = var.ttl
  records = [data.aws_lb.default.dns_name]
}

resource "aws_lb_target_group" "strapi" {
  name        = "strapi"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener_rule" "strapi" {
  listener_arn = data.aws_lb_listener.default.arn
  priority     = 121

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi.arn
  }

  condition {
    host_header {
      values = [aws_route53_record.strapi.name]
    }
  }
}

resource "aws_service_discovery_service" "strapi" {
  name = "strapi"

  health_check_custom_config {
    failure_threshold = 3
  }

  dns_config {
    namespace_id = var.namespace_id

    dns_records {
      ttl  = 300
      type = "A"
    }
  }
}
