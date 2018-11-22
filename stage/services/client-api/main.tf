resource "aws_ecs_service" "client-api-stage" {
  name = "client-api-stage"
  cluster = "${data.aws_ecs_cluster.stage.id}"
  task_definition = "${aws_ecs_task_definition.client-api-stage.arn}"
  desired_count = 1
  iam_role        = "${data.aws_iam_role.ecs_service.arn}"

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.client-api-stage.id}"
    container_name   = "client-api-stage"
    container_port   = "80"
  }
}

resource "aws_cloudwatch_log_group" "client-api-stage" {
  name = "/ecs/client-api-stage"
}

resource "aws_ecs_task_definition" "client-api-stage" {
  family = "client-api-stage"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  container_definitions =  "${data.template_file.client-api_task.rendered}"
}

resource "aws_lb_target_group" "client-api-stage" {
  name     = "client-api-stage"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/heartbeat"
  }
}

// resource "aws_lb_listener_rule" "client-api-stage" {
//   listener_arn = "${data.aws_lb_listener.stage.arn}"
//   priority     = 30

//   action {
//     type             = "forward"
//     target_group_arn = "${aws_lb_target_group.client-api-stage.arn}"
//   }

//   condition {
//     field  = "host-header"
//     values = ["${aws_route53_record.client-api-stage.name}"]
//   }
// }

resource "aws_lb_listener_rule" "api-stage" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
  priority     = 33

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.client-api-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.api_dns_name}"]
  }
}
