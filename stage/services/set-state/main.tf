resource "aws_cloudwatch_event_rule" "set-state-test" {
  name = "set-state-test"
  description = "Run set-state API call via cron"
  schedule_expression = "cron(05 1,5,9,13,17,21 * * ? *)"
}

resource "aws_cloudwatch_event_target" "set-state-test" {
  target_id = "set-state-test"
  rule = "${aws_cloudwatch_event_rule.set-state-test.name}"
  arn = "${aws_lambda_function.set-state-test.arn}"
}

resource "aws_lambda_function" "set-state-test" {
  filename = "set_state_runner.js.zip"
  function_name = "set-state-test"
  role = "${data.aws_iam_role.lambda.arn}"
  handler = "set_state_runner.handler"
  runtime = "nodejs4.3"
  source_code_hash = "${base64sha256(file("set_state_runner.js.zip"))}"

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

resource "aws_lambda_permission" "set-state-test" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.set-state-test.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.set-state-test.arn}"
}
