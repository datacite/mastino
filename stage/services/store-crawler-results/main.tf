resource "aws_cloudwatch_event_rule" "store-crawler-results-test" {
  name                = "store-crawler-results-test"
  description         = "Run store-crawler-results API call via cron"
  schedule_expression = "cron(0/30 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "store-crawler-results-test" {
  target_id = "store-crawler-results-test"
  rule      = aws_cloudwatch_event_rule.store-crawler-results-test.name
  arn       = aws_lambda_function.store-crawler-results-test.arn
}

resource "aws_lambda_function" "store-crawler-results-test" {
  filename         = "store_crawler_results.py.zip"
  function_name    = "store-crawler-results-test"
  role             = data.aws_iam_role.lambda.arn
  handler          = "store_crawler_results_runner.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = sha256(filebase64("store_crawler_results.py.zip"))
  timeout          = "270"

  vpc_config {
    subnet_ids         = [data.aws_subnet.datacite-private.id, data.aws_subnet.datacite-alt.id]
    security_group_ids = [data.aws_security_group.datacite-private.id]
  }

  environment {
    variables = {
      REDIS_HOST     = var.redis_host
      API_ENDPOINT   = var.api_endpoint
      ADMIN_USERNAME = var.admin_username
      ADMIN_PASSWORD = var.admin_password
    }
  }
}

resource "aws_lambda_permission" "store-crawler-results-test" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.store-crawler-results-test.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.store-crawler-results-test.arn
}
