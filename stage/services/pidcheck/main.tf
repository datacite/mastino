
resource "aws_ecs_service" "pidcheck-stage" {
  name            = "pidcheck-stage"
  cluster         = "${data.aws_ecs_cluster.stage.id}"
  task_definition = "${aws_ecs_task_definition.pidcheck-stage.arn}"
  desired_count   = 1

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
}

resource "aws_cloudwatch_log_group" "pidcheck-stage" {
  name = "/ecs/pidcheck-stage"
}

resource "aws_ecs_task_definition" "pidcheck-stage" {
  family                = "pidcheck-stage"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  container_definitions = "${data.template_file.pidcheck_task.rendered}"
} 

