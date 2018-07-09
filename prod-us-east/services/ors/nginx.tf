resource "aws_ecs_service" "nginx" {
   name = "nginx"
   cluster = "${data.aws_ecs_cluster.default-us.id}"
   launch_type = "FARGATE"
   task_definition = "${aws_ecs_task_definition.nginx.arn}"
   desired_count = 1

   network_configuration {
      security_groups = ["${data.aws_security_group.datacite-private.id}"]
      subnets         = [
         "${data.aws_subnet.datacite-private.id}",
         "${data.aws_subnet.datacite-alt.id}"
      ]
   }

   load_balancer {
      target_group_arn = "${aws_lb_target_group.nginx.id}"
      container_name   = "nginx"
      container_port   = "80"
   }
}

resource "aws_ecs_task_definition" "nginx" {
   family = "nginx"
   execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
   requires_compatibilities = ["FARGATE"]
   network_mode = "awsvpc"
   cpu = "512"
   memory = "2048"

   container_definitions = "${data.template_file.nginx_task.rendered}"
}


resource "aws_lb_target_group" "nginx" {
   name     = "nginx"
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
   priority     = 122

   action {
      type             = "forward"
      target_group_arn = "${aws_lb_target_group.nginx.arn}"
   }

   condition {
      field  = "host-header"
      values = ["ors.test.datacite.org"]
   }
}

resource "aws_route53_record" "ors" {
   zone_id = "${data.aws_route53_zone.production.zone_id}"
   name = "ors.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.default-us.dns_name}"]
}

resource "aws_route53_record" "split-ors" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "ors.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["${data.aws_lb.default-us.dns_name}"]
}

