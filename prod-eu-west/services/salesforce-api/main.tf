resource "aws_cloudwatch_event_rule" "update-salesforce-daily" {
  name = "update-salesforce-daily"
  description = "Update salesforce daily via cron"
  schedule_expression = "cron(30 23 * * ? *)"
}

resource "aws_cloudwatch_event_target" "update-salesforce-daily" {
  target_id = "update-salesforce-daily"
  rule = aws_cloudwatch_event_rule.update-salesforce-daily.name
  arn = aws_lambda_function.update-salesforce-daily.arn
}

resource "aws_lambda_function" "update-salesforce-daily" {
  filename = "salesforce-daily_runner.js.zip"
  function_name = "update-salesforce-daily"
  role = data.aws_iam_role.lambda.arn
  handler = "salesforce-daily_runner.handler"
  runtime = "nodejs22.x"
  source_code_hash = sha256(filebase64("salesforce-daily_runner.js.zip"))
  timeout = "600"

  vpc_config {
    subnet_ids = [data.aws_subnet.datacite-private.id, data.aws_subnet.datacite-alt.id]
    security_group_ids = [data.aws_security_group.datacite-private.id]
  }
  environment {
    variables = {
      host     = var.host
      username = var.username
      password = var.password
      datacite_api_url = var.datacite_api_url
      datacite_username = var.datacite_username
      datacite_password = var.datacite_password
    }
  }
}

resource "aws_lambda_function" "salesforce-api" {
  filename = "salesforce-api_runner.js.zip"
  function_name = "salesforce-api"
  role = data.aws_iam_role.lambda.arn
  handler = "salesforce-api_runner.handler"
  runtime = "nodejs22.x"
  source_code_hash = sha256(filebase64("salesforce-api_runner.js.zip"))
  timeout = "60"

  vpc_config {
    subnet_ids = [data.aws_subnet.datacite-private.id, data.aws_subnet.datacite-alt.id]
    security_group_ids = [data.aws_security_group.datacite-private.id]
  }
  environment {
    variables = {
      host     = var.host
      username = var.username
      password = var.password
      client_id = var.client_id
      client_secret = var.client_secret
      slack_webhook_url = var.slack_webhook_url
      slack_icon_url = var.slack_icon_url
      datacite_api_url = var.datacite_api_url
      datacite_username = var.datacite_username
      datacite_password = var.datacite_password
    }
  }
}

resource "aws_lambda_permission" "update-salesforce-daily" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update-salesforce-daily.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.update-salesforce-daily.arn
}

resource "aws_lambda_permission" "salesforce-api" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.salesforce-api.function_name
  principal = "events.amazonaws.com"
}
