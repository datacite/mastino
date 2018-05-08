resource "aws_ecs_task_definition" "usage-update-test" {
  family = "usage-update-test"
  container_definitions =  "${data.template_file.usage_update_test_task.rendered}"
}

resource "aws_cloudwatch_event_rule" "usage-update-test" {
  name = "usage-update-test"
  description = "Run usage-update container via cron"
  schedule_expression = "cron(2	*	*	*	*	)"
}

resource "aws_cloudwatch_event_target" "usage-update-test" {
  target_id = "usage-update-test"
  rule = "${aws_cloudwatch_event_rule.usage-update-test.name}"
  arn = "${aws_lambda_function.usage-update-test.arn}"
}

resource "aws_lambda_function" "usage-update-test" {
  filename = "ecs_task_runner.js.zip"
  function_name = "usage-update-test"
  role = "${data.aws_iam_role.lambda.arn}"
  handler = "ecs_task_runner.handler"
  runtime = "nodejs4.3"
  vpc_config {
    subnet_ids = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
  }
  environment {
    variables = {
      ecs_task_def = "usage-update-test"
      cluster = "test"
      count = 1
    }
  }
}

resource "aws_lambda_permission" "usage-update-test" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.usage-update-test.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.usage-update-test.arn}"
}
