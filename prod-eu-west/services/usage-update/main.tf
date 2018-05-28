resource "aws_ecs_task_definition" "usage-update" {
  family = "usage-update"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  container_definitions =  "${data.template_file.usage_update_task.rendered}"
}

resource "aws_cloudwatch_event_rule" "usage-update" {
  name = "usage-update"
  description = "Run usage-update container via cron"
  schedule_expression = "cron(30	*	*	*	? *)"
}

resource "aws_cloudwatch_event_target" "usage-update" {
  target_id = "usage-update"
  rule = "${aws_cloudwatch_event_rule.usage-update.name}"
  arn = "${aws_lambda_function.usage-update.arn}"
}

resource "aws_lambda_function" "usage-update" {
  filename = "ecs_task_runner.js.zip"
  function_name = "usage-update"
  role = "${data.aws_iam_role.lambda.arn}"
  handler = "ecs_task_runner.handler"
  runtime = "nodejs4.3"
  vpc_config {
    subnet_ids = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
  }
  environment {
    variables = {
      ecs_task_def = "usage-update"
      cluster = "deafult"
      count = 1
    }
  }
}
resource "aws_cloudwatch_log_group" "usage-update" {
  name = "/ecs/usage-update"
}

resource "aws_lambda_permission" "usage-update" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.usage-update.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.usage-update.arn}"
}
