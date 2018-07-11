resource "aws_ecs_service" "mds-stage" {
  name = "mds-stage"
  cluster = "${data.aws_ecs_cluster.stage.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.mds-stage.arn}"
  desired_count = 1

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.mds-stage.id}"
    container_name   = "mds-stage"
    container_port   = "80"
  }

  depends_on = [
    "data.aws_lb_listener.stage",
  ]
}

resource "aws_cloudwatch_log_group" "mds-stage" {
  name = "/ecs/mds-stage"
}

resource "aws_ecs_task_definition" "mds-stage" {
  family = "mds-stage"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}",
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "2048"

  container_definitions =  "${data.template_file.mds_task.rendered}"
}

resource "aws_route53_record" "mds-stage" {
   zone_id = "${data.aws_route53_zone.production.zone_id}"
   name = "mds.test.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.stage.dns_name}"]
}

resource "aws_route53_record" "split-mds-stage" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "mds.test.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.stage.dns_name}"]
}

resource "aws_lb_target_group" "mds-stage" {
  name     = "mds-stage"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    path = "/heartbeat"
  }
}

resource "aws_lb_listener_rule" "mds-stage-doi" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.mds-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.mds-stage.name}"]
  }
  
  condition {
    field  = "path-pattern"
    values = ["/doi*"]
  }
}

resource "aws_lb_listener_rule" "mds-stage-metadata" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
  priority     = 5

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.mds-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.mds-stage.name}"]
  }

  condition {
    field  = "path-pattern"
    values = ["/metadata*"]
  }
}

resource "aws_lb_listener_rule" "mds-stage-media" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
  priority     = 6

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.mds-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.mds-stage.name}"]
  }

  condition {
    field  = "path-pattern"
    values = ["/media*"]
  }
}

resource "aws_lb_listener_rule" "mds-stage-heartbeat" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
  priority     = 7

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.mds-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.mds-stage.name}"]
  }

  condition {
    field  = "path-pattern"
    values = ["/heartbeat"]
  }
}