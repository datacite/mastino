resource "aws_ecs_service" "mds-test" {
  name = "mds-test"
  cluster = data.aws_ecs_cluster.test.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.mds-test.arn
  desired_count = 1

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.mds-test.id
    container_name   = "mds-test"
    container_port   = "80"
  }

  depends_on = [
    "data.aws_lb_listener.test"
  ]
}

resource "aws_cloudwatch_log_group" "mds-test" {
  name = "/ecs/mds-test"
}

resource "aws_ecs_task_definition" "mds-test" {
  family = "mds-test"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"
  container_definitions = templatefile("mds.json",
    {
      sentry_dsn         = var.sentry_dsn
      api_url            = var.api_url
      realm              = var.realm
      memcache_servers   = var.memcache_servers
      version            = var.poodle_tags["version"]
      sha                = var.poodle_tags["sha"]
    })
}

resource "aws_route53_record" "mds-test" {
   zone_id = data.aws_route53_zone.production.zone_id
   name = "mds.test.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [data.aws_lb.test.dns_name]
}

resource "aws_route53_record" "split-mds-test" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "mds.test.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [data.aws_lb.test.dns_name]
}

resource "aws_lb_target_group" "mds-test" {
  name     = "mds-test"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "mds-test" {
  listener_arn = data.aws_lb_listener.test.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mds-test.arn
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.mds-test.name]
  }
}

// resource "aws_lb_listener_rule" "mds-test-doi" {
//   listener_arn = data.aws_lb_listener.test.arn
//   priority     = 2

//   action {
//     type             = "forward"
//     target_group_arn = aws_lb_target_group.mds-test.arn
//   }

//   condition {
//     field  = "host-header"
//     values = [aws_route53_record.mds-test.name]
//   }
  
//   condition {
//     field  = "path-pattern"
//     values = ["/doi*"]
//   }
// }

// resource "aws_lb_listener_rule" "mds-test-metadata" {
//   listener_arn = data.aws_lb_listener.test.arn
//   priority     = 5

//   action {
//     type             = "forward"
//     target_group_arn = aws_lb_target_group.mds-test.arn
//   }

//   condition {
//     field  = "host-header"
//     values = [aws_route53_record.mds-test.name]
//   }

//   condition {
//     field  = "path-pattern"
//     values = ["/metadata*"]
//   }
// }

// resource "aws_lb_listener_rule" "mds-test-media" {
//   listener_arn = data.aws_lb_listener.test.arn
//   priority     = 6

//   action {
//     type             = "forward"
//     target_group_arn = aws_lb_target_group.mds-test.arn
//   }

//   condition {
//     field  = "host-header"
//     values = [aws_route53_record.mds-test.name]
//   }

//   condition {
//     field  = "path-pattern"
//     values = ["/media*"]
//   }
// }

resource "aws_lb_listener_rule" "mds-test-heartbeat" {
  listener_arn = data.aws_lb_listener.test.arn
  priority     = 7

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mds-test.arn
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.mds-test.name]
  }

  condition {
    field  = "path-pattern"
    values = ["/heartbeat"]
  }
}