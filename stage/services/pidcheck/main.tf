
resource "aws_ecs_service" "pidcheck-stage" {
  name            = "pidcheck-stage"
  cluster         = "${data.aws_ecs_cluster.stage.id}"
  launch_type     = "FARGATE"
  task_definition = "${aws_ecs_task_definition.pidcheck-stage.arn}"
  desired_count   = 1

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }
}

resource "aws_cloudwatch_log_group" "pidcheck-stage" {
  name = "/ecs/pidcheck-stage"
}

resource "aws_ecs_task_definition" "pidcheck-stage" {
  family                = "pidcheck-stage"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"

  container_definitions = "${data.template_file.pidcheck_task.rendered}"
}

