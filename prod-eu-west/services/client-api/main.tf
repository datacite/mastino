resource "aws_ecs_service" "client-api" {
  name = "client-api"
  cluster = "${data.aws_ecs_cluster.default.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.client-api.arn}"
  desired_count = 4

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.client-api.id}"
    container_name   = "client-api"
    container_port   = "80"
  }

  // service_registries {
  //   registry_arn = "${aws_service_discovery_service.client-api.arn}"
  // }

  depends_on = [
    "data.aws_lb_listener.default",
  ]
}

resource "aws_cloudwatch_log_group" "client-api" {
  name = "/ecs/client-api"
}

resource "aws_ecs_task_definition" "client-api" {
  family = "client-api"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "1024"
  memory = "2048"
  container_definitions =  "${data.template_file.client-api_task.rendered}"
}

resource "aws_lb_target_group" "client-api" {
  name     = "client-api"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/heartbeat"
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

// resource "aws_service_discovery_service" "client-api" {
//   name = "client-api"

//   health_check_custom_config {
//     failure_threshold = 3
//   }

//   dns_config {
//     namespace_id = "${var.namespace_id}"
    
//     dns_records {
//       ttl = 300
//       type = "A"
//     }
//   }
// }
