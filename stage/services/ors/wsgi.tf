# WSGI Service
resource "aws_ecs_service" "wsgi-stage" {
   name = "wsgi-stage"
   cluster = "${data.aws_ecs_cluster.stage.id}"
   launch_type = "FARGATE"
   task_definition = "${aws_ecs_task_definition.wsgi-stage.arn}"
   desired_count = 1

   network_configuration {
      security_groups = ["${data.aws_security_group.datacite-private.id}"]
      subnets         = [
         "${data.aws_subnet.datacite-private.id}",
         "${data.aws_subnet.datacite-alt.id}"
      ]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.wsgi-stage.id}"
    container_name   = "bagit-stage"
    container_port   = "80"
  }

  depends_on = [
    "data.aws_lb_listener.stage",
  ]

  //  service_registries {
  //     registry_arn = "${aws_service_discovery_service.wsgi.arn}"
  //  }

}

resource "aws_cloudwatch_log_group" "wsgi-stage" {
  name = "/ecs/wsgi-stage"
}

# WSGI Task Definition
resource "aws_ecs_task_definition" "wsgi-stage" {
   family = "wsgi-stage"
   execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
   requires_compatibilities = ["FARGATE"]
   network_mode = "awsvpc"
   cpu = "512"
   memory = "2048"

   container_definitions = "${data.template_file.wsgi_task.rendered}"
}

resource "aws_lb_target_group" "wsgi-stage" {
   name     = "wsgi-stage"
   port     = 80
   protocol = "HTTP"
   vpc_id   = "${var.vpc_id}"
   target_type = "ip"

   health_check {
      path = "/"
   }
}

resource "aws_lb_listener_rule" "wsgi-stage" {
   listener_arn = "${data.aws_lb_listener.stage.arn}"
   priority     = 133

   action {
      type             = "forward"
      target_group_arn = "${aws_lb_target_group.wsgi-stage.arn}"
   }

   condition {
      field  = "host-header"
      values = ["wsgi.test.datacite.org"]
   }
}

resource "aws_route53_record" "split-wsgi-stage" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "wsgi.test.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.stage.dns_name}"]
}

# WSGI Service Discovery
// resource "aws_service_discovery_service" "wsgi" {
//    name = "wsgi"

//    health_check_custom_config {
//       failure_threshold = 1
//    }

//    dns_config {
//       namespace_id = "${aws_service_discovery_private_dns_namespace.ors_namespace.id}"
//       dns_records {
//          ttl = 6000
//          type = "A"
//       }
//    }

// }

