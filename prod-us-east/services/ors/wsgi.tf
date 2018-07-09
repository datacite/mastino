# WSGI Service
resource "aws_ecs_service" "wsgi" {
   name = "wsgi"
   cluster = "${data.aws_ecs_cluster.default-us.id}"
   launch_type = "FARGATE"
   task_definition = "${aws_ecs_task_definition.wsgi.arn}"
   desired_count = 1

   network_configuration {
      security_groups = ["${data.aws_security_group.datacite-private.id}"]
      subnets         = [
         "${data.aws_subnet.datacite-private.id}",
         "${data.aws_subnet.datacite-alt.id}"
      ]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.wsgi.id}"
    container_name   = "wsgi"
    container_port   = "80"
  }

  //  service_registries {
  //     registry_arn = "${aws_service_discovery_service.wsgi.arn}"
  //  }

}

resource "aws_cloudwatch_log_group" "wsgi" {
  name = "/ecs/wsgi"
}

# WSGI Task Definition
resource "aws_ecs_task_definition" "wsgi" {
   family = "wsgi"
   execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
   requires_compatibilities = ["FARGATE"]
   network_mode = "awsvpc"
   cpu = "512"
   memory = "2048"

   container_definitions = "${data.template_file.wsgi_task.rendered}"
}

resource "aws_lb_target_group" "wsgi" {
   name     = "wsgi"
   port     = 80
   protocol = "HTTP"
   vpc_id   = "${var.vpc_id}"
   target_type = "ip"

   health_check {
      path = "/"
   }
}

resource "aws_lb_listener_rule" "wsgi" {
   listener_arn = "${data.aws_lb_listener.default-us.arn}"
   priority     = 130

   action {
      type             = "forward"
      target_group_arn = "${aws_lb_target_group.wsgi.arn}"
   }

   condition {
      field  = "host-header"
      values = ["wsgi.datacite.org"]
   }
}

resource "aws_route53_record" "split-wsgi" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "wsgi.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.default-us.dns_name}"]
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

