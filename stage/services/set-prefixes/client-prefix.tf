resource "aws_cloudwatch_event_rule" "set-client-created-test" {
  name = "set-client-created-test"
  description = "Run set-client-created API call via cron"
  schedule_expression = "cron(35 1 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "set-client-provider-test" {
  name = "set-client-provider-test"
  description = "Run set-client-provider API call via cron"
  schedule_expression = "cron(40 1 * * ? *)"
}

resource "aws_cloudwatch_event_target" "set-client-created-test" {
  target_id = "set-client-created-test"
  rule = "${aws_cloudwatch_event_rule.set-client-created-test.name}"
  arn = "${aws_lambda_function.set-client-created-test.arn}"
}

resource "aws_cloudwatch_event_target" "set-client-provider-test" {
  target_id = "set-client-provider-test"
  rule = "${aws_cloudwatch_event_rule.set-client-provider-test.name}"
  arn = "${aws_lambda_function.set-client-provider-test.arn}"
}

resource "aws_lambda_function" "set-client-created-test" {
  filename = "set_prefixes_runner.js.zip"
  function_name = "set-client-created-test"
  role = "${data.aws_iam_role.lambda.arn}"
  handler = "set_prefixes_runner.handler"
  runtime = "nodejs6.10"
  source_code_hash = "${base64sha256(file("set_prefixes_runner.js.zip"))}"
  timeout = "270"

  vpc_config {
    subnet_ids = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
  }
  environment {
    variables = {
      host     = "${var.host}"
      path     = "${var.client_created_path}"
      username = "${var.username}"
      password = "${var.password}"
    }
  }
}

resource "aws_lambda_function" "set-client-provider-test" {
  filename = "set_prefixes_runner.js.zip"
  function_name = "set-client-provider-test"
  role = "${data.aws_iam_role.lambda.arn}"
  handler = "set_prefixes_runner.handler"
  runtime = "nodejs6.10"
  source_code_hash = "${base64sha256(file("set_prefixes_runner.js.zip"))}"
  timeout = "270"

  vpc_config {
    subnet_ids = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
  }
  environment {
    variables = {
      host     = "${var.host}"
      path     = "${var.client_provider_path}"
      username = "${var.username}"
      password = "${var.password}"
    }
  }
}

resource "aws_lambda_permission" "set-client-created-test" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.set-client-created-test.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.set-client-created-test.arn}"
}

resource "aws_lambda_permission" "set-client-provider-test" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.set-client-provider-test.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.set-client-provider-test.arn}"
}
