resource "aws_ecs_task_definition" "datacite-related-test" {
  family = "datacite-related-test"
  container_definitions =  "${data.template_file.datacite_related_test_task.rendered}"
}

resource "aws_cloudwatch_event_rule" "datacite-related-test" {
  name = "datacite-related-test"
  description = "Run datacite-related container via cron"
  schedule_expression = "cron(40 4 * * ? *)"
}

resource "aws_cloudwatch_event_target" "datacite-related-test" {
  target_id = "datacite-related-test"
  rule = "${aws_cloudwatch_event_rule.datacite-related-test.name}"
  arn = "${aws_lambda_function.datacite-related-test.arn}"
}

resource "aws_lambda_function" "datacite-related-test" {
  filename = "ecs_task_runner.js.zip"
  function_name = "datacite-related-test"
  role = "${data.aws_iam_role.lambda.arn}"
  handler = "ecs_task_runner.handler"
  runtime = "nodejs4.3"
  vpc_config {
    subnet_ids = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
  }
  environment {
    variables = {
      ecs_task_def = "datacite-related-test"
      cluster = "test"
      count = 1
    }
  }
}

resource "aws_lambda_permission" "datacite-related-test" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.datacite-related-test.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.datacite-related-test.arn}"
}
