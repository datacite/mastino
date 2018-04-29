resource "aws_ecs_service" "re3data-stage" {
  name = "re3data-stage"
  cluster = "${data.aws_ecs_cluster.stage.id}"
  task_definition = "${aws_ecs_task_definition.re3data-stage.arn}"
  desired_count = 1
  iam_role        = "${data.aws_iam_role.ecs_service.arn}"

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.re3data-stage.id}"
    container_name   = "re3data-stage"
    container_port   = "80"
  }
}

resource "aws_ecs_task_definition" "re3data-stage" {
  family = "re3data-stage"
  container_definitions =  "${data.template_file.re3data_task.rendered}"
}

resource "aws_lb_target_group" "re3data-stage" {
  name     = "re3data-stage"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener_rule" "re3data-stage" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
  priority     = 32

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.re3data-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["api.test.datacite.org"]
  }

  condition {
    field  = "path-pattern"
    values = ["/repositories*"]
  }
}

// resource "aws_route53_record" "re3data-stage" {
//     zone_id = "${data.aws_route53_zone.production.zone_id}"
//     name = "re3data.test.datacite.org"
//     type = "CNAME"
//     ttl = "${var.ttl}"
//     records = ["${data.aws_lb.stage.dns_name}"]
// }

// resource "aws_route53_record" "split-re3data-stage" {
//     zone_id = "${data.aws_route53_zone.internal.zone_id}"
//     name = "re3data.test.datacite.org"
//     type = "CNAME"
//     ttl = "${var.ttl}"
//     records = ["${data.aws_lb.stage.dns_name}"]
// }
