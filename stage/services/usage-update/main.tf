resource "aws_ecs_task_definition" "usage-update-stage" {
  family = "usage-update-stage"
  container_definitions =  "${data.template_file.usage_update_stage_task.rendered}"
}

resource "aws_cloudwatch_event_rule" "usage-update-stage" {
  name = "usage-update-stage"
  description = "Run usage-update container via cron"
  schedule_expression = "cron(2	*	*	*	* *)"
}

resource "aws_cloudwatch_event_target" "usage-update-stage" {
  target_id = "usage-update-stage"
  rule = "${aws_cloudwatch_event_rule.usage-update-stage.name}"
  arn = "${aws_lambda_function.usage-update-stage.arn}"
}

resource "aws_lambda_function" "usage-update-stage" {
  filename = "ecs_task_runner.js.zip"
  function_name = "usage-update-stage"
  role = "${data.aws_iam_role.lambda.arn}"
  handler = "ecs_task_runner.handler"
  runtime = "nodejs4.3"
  vpc_config {
    subnet_ids = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
  }
  environment {
    variables = {
      ecs_task_def = "usage-update-stage"
      cluster = "stage"
      count = 1
    }
  }
}

resource "aws_lambda_permission" "usage-update-stage" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.usage-update-stage.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.usage-update-stage.arn}"
}
