resource "aws_cloudwatch_event_rule" "check-links" {
  name                = "check-links"
  description         = "Run check-links API call via cron"
  schedule_expression = "cron(0 1 * * ? *)"
}

resource "aws_cloudwatch_event_target" "check-links" {
  target_id = "check-links"
  rule      = "${aws_cloudwatch_event_rule.check-links.name}"
  arn       = "${aws_lambda_function.check-links.arn}"
}

resource "aws_lambda_function" "check-links" {
  filename         = "check_links.py.zip"
  function_name    = "check-links"
  role             = "${data.aws_iam_role.lambda.arn}"
  handler          = "check_links_runner.lambda_handler"
  runtime          = "python3.6"
  source_code_hash = "${base64sha256(file("check_links.py.zip"))}"
  timeout          = "270"

  vpc_config {
    subnet_ids         = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
  }

  environment {
    variables = {
      redis_host     = "${var.redis_host}"
      start_urls_key = "${var.start_urls_key}"
    }
  }
}

resource "aws_lambda_permission" "check-links" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.check-links.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.check-links.arn}"
}
