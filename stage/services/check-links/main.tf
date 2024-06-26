resource "aws_cloudwatch_event_rule" "check-links-test" {
  name                = "check-links-test"
  description         = "Run check-links API call via cron"
  schedule_expression = "cron(42 1 * * ? *)"
}

resource "aws_cloudwatch_event_target" "check-links-test" {
  target_id = "check-links-test"
  rule      = aws_cloudwatch_event_rule.check-links-test.name
  arn       = aws_lambda_function.check-links-test.arn
}

resource "aws_lambda_function" "check-links-test" {
  filename         = "check_links.py.zip"
  function_name    = "check-links-test"
  role             = data.aws_iam_role.lambda.arn
  handler          = "check_links_runner.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = sha256(filebase64("check_links.py.zip"))
  timeout          = "270"

  vpc_config {
    subnet_ids         = [data.aws_subnet.datacite-private.id, data.aws_subnet.datacite-alt.id]
    security_group_ids = [data.aws_security_group.datacite-private.id]
  }

  environment {
    variables = {
      REDIS_HOST     = var.redis_host
      START_URLS_KEY = var.start_urls_key
      API_ENDPOINT   = var.api_endpoint
    }
  }
}

resource "aws_lambda_permission" "check-links-test" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.check-links-test.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.check-links-test.arn
}
