resource "aws_ecs_service" "resolution-logs-pipeline-stage" {
  name            = "resolution-logs-pipeline-stage"
  cluster         = "${data.aws_ecs_cluster.stage.id}"
  task_definition = "${aws_ecs_task_definition.resolution-logs-pipeline-stage.arn}"
  desired_count   = 1

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
}

resource "aws_cloudwatch_log_group" "resolution-logs-pipeline-stage" {
  name = "/ecs/resolution-logs-pipeline-stage"
}

resource "aws_ecs_task_definition" "resolution-logs-pipeline-stage" {
  family = "resolution-logs-pipeline-stage"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  container_definitions =  "${data.template_file.resolution-logs-pipeline_task.rendered}"
}
