data "aws_ecs_cluster" "ecs_cluster" {
  cluster_name = var.env
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

data "aws_security_group" "datacite-private" {
  id = var.security_group_id
}

data "aws_subnet" "datacite-private" {
  id = var.subnet_datacite-private_id
}

data "aws_subnet" "datacite-alt" {
  id = var.subnet_datacite-alt_id
}

data "aws_lb" "lb" {
  name = var.lb_name
}

data "aws_lb_listener" "lb_listener" {
  load_balancer_arn = data.aws_lb.lb.arn
  port = 443
}

data "aws_route53_zone" "production" {
  name = "datacite.org"
}

data "aws_route53_zone" "internal" {
  name = "datacite.org"
  private_zone = true
}

resource "aws_ecs_service" "ecs-service" {
  name            = "${var.app_name}-${var.env}"
  launch_type     = var.launch_type
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = var.desired_container_count

  depends_on      = [
    data.aws_lb_listener.lb_listener,
  ]

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id,
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group.id
    container_name   = var.app_name
    container_port   = var.container_port
  }

  service_registries {
    registry_arn = aws_service_discovery_service.service-discovery.arn
  }

}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "${var.app_name}-${var.env}"
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family = var.app_name
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  cpu = var.task_cpu
  memory = var.task_memory

  container_definitions = var.container_definition_json
}

resource "aws_service_discovery_service" "service_discovery" {
  name = "${var.app_name}.${var.env}"

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

resource "aws_lb_target_group" "lb_target_group" {
  name     = "${var.app_name}-${var.env}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
  slow_start = 240

  health_check {
    path = var.health_check_path
  }
}


resource "aws_lb_listener_rule" "primary_listener_rule" {
  listener_arn = aws_lb_listener.lb_listener.arn
  priority     = var.lb_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.id
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.primary_record.name]
  }
}

resource "aws_route53_record" "primary_record" {
    zone_id = data.aws_route53_zone.production.zone_id
    name = var.dns_record_name
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.default.dns_name]
}

resource "aws_route53_record" "split_record" {
    zone_id = data.aws_route53_zone.internal.zone_id
    name = var.dns_record_name
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.default.dns_name]
}
