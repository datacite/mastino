resource "aws_ecs_service" "http-redirect-stage" {
  name = "http-redirect-stage"
  cluster = "${data.aws_ecs_cluster.stage.id}"
  task_definition = "${aws_ecs_task_definition.http-redirect-stage.arn}"
  desired_count = 1
  iam_role        = "${data.aws_iam_role.ecs_service.arn}"

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.http-redirect-stage.id}"
    container_name   = "http-redirect-stage"
    container_port   = "80"
  }
}

resource "aws_lb_target_group" "http-redirect-stage" {
  name     = "http-redirect-stage"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_ecs_task_definition" "http-redirect-stage" {
  family = "http-redirect-stage"
  container_definitions =  "${data.template_file.http-redirect_task.rendered}"
}
