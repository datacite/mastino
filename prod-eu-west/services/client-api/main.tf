resource "aws_ecs_service" "client-api" {
  name = "client-api"
  cluster = "${data.aws_ecs_cluster.default.id}"
  task_definition = "${aws_ecs_task_definition.client-api.arn}"
  desired_count = 3
  iam_role        = "${data.aws_iam_role.ecs_service.arn}"

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.client-api.id}"
    container_name   = "client-api"
    container_port   = "80"
  }
}

resource "aws_cloudwatch_log_group" "client-api" {
  name = "/ecs/client-api"
}

resource "aws_ecs_task_definition" "client-api" {
  family = "client-api"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  container_definitions =  "${data.template_file.client-api_task.rendered}"
}

resource "aws_lb_target_group" "client-api" {
  name     = "client-api"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/"
  }
}

// resource "aws_lb_listener_rule" "client-api" {
//   listener_arn = "${data.aws_lb_listener.default.arn}"
//   priority     = 20

//   action {
//     type             = "forward"
//     target_group_arn = "${aws_lb_target_group.client-api.arn}"
//   }

//   condition {
//     field  = "host-header"
//     values = ["${aws_route53_record.client-api.name}"]
//   }
// }

resource "aws_lb_listener_rule" "api" {
  listener_arn = "${data.aws_lb_listener.default.arn}"
  priority     = 41

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.client-api.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.api_dns_name}"]
  }
}

// resource "aws_route53_record" "client-api" {
//     zone_id = "${data.aws_route53_zone.production.zone_id}"
//     name = "api.datacite.org"
//     type = "CNAME"
//     ttl = "${var.ttl}"
//     records = ["${data.aws_lb.default.dns_name}"]
// }

// resource "aws_route53_record" "split-client-api" {
//     zone_id = "${data.aws_route53_zone.internal.zone_id}"
//     name = "api.datacite.org"
//     type = "CNAME"
//     ttl = "${var.ttl}"
//     records = ["${data.aws_lb.default.dns_name}"]
// }
