resource "aws_cloudwatch_event_rule" "set-state" {
  name = "set-state"
  description = "Run set-state API call via cron"
  schedule_expression = "cron(05 1,5,9,13,17,21 * * ? *)"
}

resource "aws_cloudwatch_event_target" "set-state" {
  target_id = "set-state"
  rule = "${aws_cloudwatch_event_rule.set-state.name}"
  arn = "${aws_lambda_function.set-state.arn}"
}

resource "aws_lambda_function" "set-state" {
  filename = "set_state_runner.js.zip"
  function_name = "set-state"
  role = "${data.aws_iam_role.lambda.arn}"
  handler = "set_state_runner.handler"
  runtime = "nodejs6.10"
  source_code_hash = "${base64sha256(file("set_state_runner.js.zip"))}"
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

resource "aws_lambda_permission" "set-state" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.set-state.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.set-state.arn}"
}
