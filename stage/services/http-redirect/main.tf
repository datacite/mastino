resource "aws_ecs_service" "http-redirect-test" {
  name = "http-redirect-test"
  cluster = "${data.aws_ecs_cluster.test.id}"
  task_definition = "${aws_ecs_task_definition.http-redirect-test.arn}"
  desired_count = 1
  iam_role        = "${data.aws_iam_role.ecs_service.arn}"

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.http-redirect-test.id}"
    container_name   = "http-redirect-test"
    container_port   = "80"
  }

  depends_on = [
    "aws_iam_role_policy.ecs_service",
    "aws_lb_listener.test",
  ]
}

resource "aws_lb_target_group" "http-redirect-test" {
  name     = "http-redirect-test"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_ecs_task_definition" "http-redirect-test" {
  family = "http-redirect-test"
  container_definitions =  "${data.template_file.http-redirect_task.rendered}"
}
