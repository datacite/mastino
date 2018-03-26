
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

resource "aws_ecs_task_definition" "pidcheck-stage" {
  family                = "pidcheck-stage"
  container_definitions = "${data.template_file.pidcheck_task.rendered}"
} 

