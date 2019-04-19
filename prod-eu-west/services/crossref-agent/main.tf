resource "aws_cloudwatch_event_rule" "crossref-agent" {
  name = "crossref-agent"
  description = "Trigger crossref agent via cron"
  schedule_expression = "cron(55 8 * * ? *)"
}

resource "aws_cloudwatch_event_target" "crossref-agent" {
  target_id = "crossref-agent"
  rule = "${aws_cloudwatch_event_rule.crossref-agent.name}"
  arn = "${aws_lambda_function.crossref-agent.arn}"
}

resource "aws_lambda_function" "crossref-agent" {
  filename = "crossref-agent_runner.js.zip"
  function_name = "crossref-agent"
  role = "${data.aws_iam_role.lambda.arn}"
  handler = "crossref-agent_runner.handler"
  runtime = "nodejs8.10"
  source_code_hash = "${base64sha256(file("crossref-agent_runner.js.zip"))}"
  timeout = "270"

  vpc_config {
    subnet_ids = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
  }
  environment {
    variables = {
      host     = "${var.host}"
      token    = "${var.token}"
    }
  }
}

resource "aws_lambda_permission" "crossref-agent" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.crossref-agent.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.crossref-agent.arn}"
}
