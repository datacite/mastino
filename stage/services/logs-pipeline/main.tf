resource "aws_ecs_service" "logs-pipeline-stage" {
  name            = "logs-pipeline-stage"
  cluster         = "${data.aws_ecs_cluster.stage.id}"
  task_definition = "${aws_ecs_task_definition.logs-pipeline-stage.arn}"
  desired_count   = 1
  iam_role        = "${data.aws_iam_role.ecs_service.arn}"

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
}

resource "aws_cloudwatch_log_group" "logs-pipeline-stage" {
  name = "/ecs/logs-pipeline-stage"
}

resource "aws_ecs_task_definition" "logs-pipeline-stage" {
  family = "logs-pipeline-stage"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  container_definitions =  "${data.template_file.logs-pipeline_task.rendered}"
}
