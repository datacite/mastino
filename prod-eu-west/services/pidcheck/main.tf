resource "aws_ecs_service" "pidcheck" {
  name            = "pidcheck"
  cluster         = "${data.aws_ecs_cluster.default.id}"
  launch_type     = "FARGATE"
  task_definition = "${aws_ecs_task_definition.pidcheck.arn}"
  desired_count   = 1

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }
}

resource "aws_cloudwatch_log_group" "pidcheck" {
  name = "/ecs/pidcheck"
}

resource "aws_ecs_task_definition" "pidcheck" {
  family                = "pidcheck"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "384"

  container_definitions = "${data.template_file.pidcheck_task.rendered}"
}
