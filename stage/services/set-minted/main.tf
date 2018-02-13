resource "aws_cloudwatch_event_rule" "set-minted-test" {
  name = "set-minted-test"
  description = "Run set-minted API call via cron"
  schedule_expression = "cron(55 0,12 * * ? *)"
}

resource "aws_cloudwatch_event_target" "set-minted-test" {
  target_id = "set-minted-test"
  rule = "${aws_cloudwatch_event_rule.set-minted-test.name}"
  arn = "${aws_lambda_function.set-minted-test.arn}"
}

resource "aws_lambda_function" "set-minted-test" {
  filename = "set_minted_runner.js.zip"
  function_name = "set-minted-test"
  role = "${data.aws_iam_role.lambda.arn}"
  handler = "set_minted_runner.handler"
  runtime = "nodejs6.10"
  source_code_hash = "${base64sha256(file("set_minted_runner.js.zip"))}"
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

resource "aws_lambda_permission" "set-minted-test" {
  mintedment_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.set-minted-test.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.set-minted-test.arn}"
}
