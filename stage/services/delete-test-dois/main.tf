resource "aws_cloudwatch_event_rule" "delete-test-dois-test" {
  name = "delete-test-dois-test"
  description = "Run delete-test-dois API call via cron"
  schedule_expression = "cron(15 1 * * ? *)"
}

resource "aws_cloudwatch_event_target" "delete-test-dois-test" {
  target_id = "delete-test-dois-test"
  rule = "${aws_cloudwatch_event_rule.delete-test-dois-test.name}"
  arn = "${aws_lambda_function.delete-test-dois-test.arn}"
}

resource "aws_lambda_function" "delete-test-dois-test" {
  filename = "delete-test-dois-test.js.zip"
  function_name = "delete-test-dois-test"
  role = "${data.aws_iam_role.lambda.arn}"
  handler = "delete-test-dois_runner.handler"
  runtime = "nodejs6.10"
  source_code_hash = "${base64sha256(file("delete-test-dois_runner.js.zip"))}"
  timeout = "270"

  vpc_config {
    subnet_ids = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
  }
  environment {
    variables = {
      host     = "${var.host}"
      username = "${var.username}"
      password = "${var.password}"
    }
  }
}

resource "aws_lambda_permission" "delete-test-dois-test" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.set-state-test.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.set-state-test.arn}"
}
