// Task Definition


# Indexd Service
resource "aws_ecs_service" "indexd-stage" {
   name = "indexd-stage"
   cluster = "${data.aws_ecs_cluster.stage.id}"
   launch_type = "FARGATE"
   task_definition = "${aws_ecs_task_definition.indexd-stage.arn}"
   desired_count = 1

  load_balancer {
    target_group_arn = "${aws_lb_target_group.indexd-stage.id}"
    container_name   = "wsgi-stage"
    container_port   = "3031"
  }

   network_configuration {
      security_groups = ["${data.aws_security_group.datacite-private.id}"]
      subnets         = [
         "${data.aws_subnet.datacite-private.id}",
         "${data.aws_subnet.datacite-alt.id}"
      ]
  }

  depends_on = [
    "data.aws_lb_listener.stage",
  ]

}

resource "aws_cloudwatch_log_group" "indexd-stage" {
  name = "/ecs/indexd-stage"
}

resource "aws_ecs_task_definition" "indexd-stage" {
   family = "wsgi-stage"
   execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
   requires_compatibilities = ["FARGATE"]
   network_mode = "awsvpc"
   cpu = "512"
   memory = "2048"

   container_definitions = "${data.template_file.indexd_task.rendered}"
}

resource "aws_lb_target_group" "indexd-stage" {
   name     = "wsgi-stage"
   port     = 80
   protocol = "HTTP"
   vpc_id   = "${var.vpc_id}"
   target_type = "ip"

   health_check {
      path = "/index"
   }
}

resource "aws_lb_listener_rule" "indexd-stage" {
   listener_arn = "${data.aws_lb_listener.stage.arn}"
   priority     = 124

   action {
      type             = "forward"
      target_group_arn = "${aws_lb_target_group.indexd-stage.arn}"
   }

   condition {
      field  = "path-pattern"
      values = ["/indexd/*"]
   }
}
