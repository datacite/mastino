resource "aws_cloudwatch_event_rule" "delete-test-dois" {
  name = "delete-test-dois"
  description = "Run delete-test-dois API call via cron"
  schedule_expression = "cron(15 1 * * ? *)"
}

resource "aws_cloudwatch_event_target" "delete-test-dois" {
  target_id = "delete-test-dois"
  rule = "${aws_cloudwatch_event_rule.delete-test-dois.name}"
  arn = "${aws_lambda_function.delete-test-dois.arn}"
}

resource "aws_lambda_function" "delete-test-dois" {
  filename = "delete-test-dois_runner.js.zip"
  function_name = "delete-test-dois"
  role = "${data.aws_iam_role.lambda.arn}"
  handler = "delete-test-dois_runner.handler"
  runtime = "nodejs8.10"
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

resource "aws_lambda_permission" "delete-test-dois" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.delete-test-dois.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.delete-test-dois.arn}"
}
