resource "aws_ecs_service" "netlify-auth-stage" {
  name = "netlify-auth-stage"
  cluster = "${data.aws_ecs_cluster.stage.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.netlify-auth-stage.arn}"
  desired_count = 1

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.netlify-auth-stage.id}"
    container_name   = "netlify-auth-stage"
    container_port   = "80"
  }

  depends_on = [
    "data.aws_lb_listener.stage",
  ]
}

resource "aws_cloudwatch_log_group" "netlify-auth-stage" {
  name = "/ecs/netlify-auth-stage"
}

resource "aws_ecs_task_definition" "netlify-auth-stage" {
  family = "netlify-auth-stage"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}",
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "1024"

  container_definitions =  "${data.template_file.netlify-auth_task.rendered}"
}

resource "aws_lb_target_group" "netlify-auth-stage" {
  name     = "netlify-auth-stage"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "ip"

  // health_check {
  //   path = "/"
  // }
}

resource "aws_lb_listener_rule" "netlify-auth-stage" {
  listener_arn = "${data.aws_lb_listener.stage.arn}"
  priority     = 61

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.netlify-auth-stage.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.netlify-auth-stage.name}"]
  }
}

resource "aws_route53_record" "netlify-auth-stage" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "auth.test.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.stage.dns_name}"]
}

resource "aws_route53_record" "split-netlify-auth-stage" {
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "auth.test.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${data.aws_lb.stage.dns_name}"]
}
