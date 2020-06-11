resource "aws_ecs_service" "strapi-stage" {
  name = "strapi-stage"
  cluster = data.aws_ecs_cluster.stage.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.strapi-stage.arn
  desired_count = 1

  # give container time to start up
  health_check_grace_period_seconds = 900

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.strapi-stage.id
    container_name   = "strapi-stage"
    container_port   = "1337"
  }

  depends_on = [
    "data.aws_lb_listener.stage",
  ]
}

resource "aws_cloudwatch_log_group" "strapi-stage" {
  name = "/ecs/strapi-stage"
}

resource "aws_ecs_task_definition" "strapi-stage" {
  family = "strapi-stage"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "2048"
  container_definitions = templatefile("strapi.json",
    {
      mysql_user         = var.mysql_user,
      mysql_password     = var.mysql_password,
      mysql_database     = var.mysql_database,
      mysql_host         = var.mysql_host
    })

}

resource "aws_route53_record" "strapi-stage" {
   zone_id = data.aws_route53_zone.production.zone_id
   name = "strapi.stage.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [data.aws_lb.stage.dns_name]
}

resource "aws_route53_record" "split-strapi-stage" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "strapi.stage.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [data.aws_lb.stage.dns_name]
}

resource "aws_lb_target_group" "strapi-stage" {
  name     = "strapi-stage"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener_rule" "strapi-stage" {
  listener_arn = data.aws_lb_listener.stage.arn
  priority     = 121

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi-stage.arn
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.strapi-stage.name]
  }
}
