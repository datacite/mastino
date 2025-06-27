resource "aws_cloudwatch_event_rule" "update-salesforce-daily-stage" {
  name = "update-salesforce-daily-stage"
  description = "Update salesforce daily via cron"
  schedule_expression = "cron(40 11 * * ? *)"
}

resource "aws_cloudwatch_event_target" "update-salesforce-daily-stage" {
  target_id = "update-salesforce-daily-stage"
  rule = aws_cloudwatch_event_rule.update-salesforce-daily-stage.name
  arn = aws_lambda_function.update-salesforce-daily-stage.arn
}

resource "aws_lambda_function" "update-salesforce-daily-stage" {
  filename = "salesforce-daily_runner.js.zip"
  function_name = "update-salesforce-daily-stage"
  role = data.aws_iam_role.lambda.arn
  handler = "salesforce-daily_runner.handler"
  runtime = "nodejs22.x"
  source_code_hash = sha256(filebase64("salesforce-daily_runner.js.zip"))
  timeout = "270"

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

resource "aws_lambda_function" "salesforce-api-stage" {
  filename = "salesforce-api_runner.js.zip"
  function_name = "salesforce-api-stage"
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

resource "aws_lambda_permission" "update-salesforce-daily-stage" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update-salesforce-daily-stage.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.update-salesforce-daily-stage.arn
}

resource "aws_lambda_permission" "salesforce-api-stage" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.salesforce-api-stage.function_name
  principal = "events.amazonaws.com"
}
