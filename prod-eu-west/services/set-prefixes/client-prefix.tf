resource "aws_cloudwatch_event_rule" "set-client-created" {
  name = "set-client-created"
  description = "Run set-client-created API call via cron"
  schedule_expression = "cron(35 2 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "set-client-provider" {
  name = "set-client-provider"
  description = "Run set-client-provider API call via cron"
  schedule_expression = "cron(40 2 * * ? *)"
}

resource "aws_cloudwatch_event_target" "set-client-created" {
  target_id = "set-client-created"
  rule = "${aws_cloudwatch_event_rule.set-client-created.name}"
  arn = "${aws_lambda_function.set-client-created.arn}"
}

resource "aws_cloudwatch_event_target" "set-client-provider" {
  target_id = "set-client-provider"
  rule = "${aws_cloudwatch_event_rule.set-client-provider.name}"
  arn = "${aws_lambda_function.set-client-provider.arn}"
}

resource "aws_lambda_function" "set-client-created" {
  filename = "set_prefixes_runner.js.zip"
  function_name = "set-client-created"
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

resource "aws_lambda_function" "set-client-provider" {
  filename = "set_prefixes_runner.js.zip"
  function_name = "set-client-provider"
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

resource "aws_lambda_permission" "set-client-created" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.set-client-created.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.set-client-created.arn}"
}

resource "aws_lambda_permission" "set-client-provider" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.set-client-provider.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.set-client-provider.arn}"
}
