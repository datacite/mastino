resource "aws_ecs_service" "doi-stage" {
  name = "doi-stage"
  cluster = "${data.aws_ecs_cluster.stage.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.doi-stage.arn}"
  desired_count = 1

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.doi-stage.id}"
    container_name   = "doi-stage"
    container_port   = "80"
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.doi-stage.arn}"
  }

  depends_on = [
    "data.aws_lb_listener.stage",
  ]
}

resource "aws_cloudwatch_log_group" "doi-stage" {
  name = "/ecs/doi-stage"
}

resource "aws_ecs_task_definition" "doi-stage" {
  family = "doi-stage"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "1024"
  memory = "2048"

  container_definitions =  "${data.template_file.doi_task.rendered}"
}

resource "aws_lb_target_group" "doi-stage" {
  name     = "doi-stage"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener_rule" "doi-stage" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
  priority     = 80

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.doi-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.doi-stage.name}"]
  }
}

resource "aws_route53_record" "doi-stage" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "doi.test.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.stage.dns_name}"]
}

resource "aws_route53_record" "split-doi-stage" {
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "doi.test.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.stage.dns_name}"]
}

resource "aws_service_discovery_service" "doi-stage" {
  name = "doi.test"

  health_check_custom_config {
    failure_threshold = 3
  }

  dns_config {
    namespace_id = "${var.namespace_id}"
    
    dns_records {
      ttl = 300
      type = "A"
    }
  }
}
