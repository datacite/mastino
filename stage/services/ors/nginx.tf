resource "aws_ecs_service" "nginx-stage" {
   name = "nginx-stage"
   cluster = "${data.aws_ecs_cluster.stage.id}"
   launch_type = "FARGATE"
   task_definition = "${aws_ecs_task_definition.nginx-stage.arn}"
   desired_count = 1

   network_configuration {
      security_groups = ["${data.aws_security_group.datacite-private.id}"]
      subnets         = [
         "${data.aws_subnet.datacite-private.id}",
         "${data.aws_subnet.datacite-alt.id}"
      ]
   }

   load_balancer {
      target_group_arn = "${aws_lb_target_group.nginx-stage.id}"
      container_name   = "nginx"
      container_port   = "80"
   }

  depends_on = [
    "data.aws_lb_listener.stage",
  ]
}

resource "aws_ecs_task_definition" "nginx-stage" {
   family = "nginx-stage"
   execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
   requires_compatibilities = ["FARGATE"]
   network_mode = "awsvpc"
   cpu = "512"
   memory = "2048"

   container_definitions = "${data.template_file.nginx_task.rendered}"
}


resource "aws_lb_target_group" "nginx-stage" {
   name     = "nginx-stage"
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
   priority     = 122

   action {
      type             = "forward"
      target_group_arn = "${aws_lb_target_group.nginx-stage.arn}"
   }

   condition {
      field  = "host-header"
      values = ["ors.test.datacite.org"]
   }
}

resource "aws_route53_record" "ors-stage" {
   zone_id = "${data.aws_route53_zone.production.zone_id}"
   name = "ors.test.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.stage.dns_name}"]
}

resource "aws_route53_record" "split-ors-stage" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "ors.test.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.stage.dns_name}"]
}