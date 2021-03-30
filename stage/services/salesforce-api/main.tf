resource "aws_cloudwatch_event_rule" "update-salesforce-hourly-stage" {
  name = "update-salesforce-hourly-stage"
  description = "Update salesforce every 15 min via cron"
  schedule_expression = "cron(* * * * ? *)"
}

resource "aws_cloudwatch_event_rule" "update-salesforce-weekly-stage" {
  name = "update-salesforce-weekly-stage"
  description = "Update salesforce weekly via cron"
  schedule_expression = "cron(50 11 * * ? *)"
}

resource "aws_cloudwatch_event_target" "update-salesforce-hourly-stage" {
  target_id = "update-salesforce-hourly-stage"
  rule = aws_cloudwatch_event_rule.update-salesforce-hourly-stage.name
  arn = aws_lambda_function.update-salesforce-hourly-stage.arn
}

resource "aws_cloudwatch_event_target" "update-salesforce-weekly-stage" {
  target_id = "update-salesforce-weekly-stage"
  rule = aws_cloudwatch_event_rule.update-salesforce-weekly-stage.name
  arn = aws_lambda_function.update-salesforce-weekly-stage.arn
}

resource "aws_lambda_function" "update-salesforce-hourly-stage" {
  filename = "salesforce-hourly_runner.js.zip"
  function_name = "update-salesforce-hourly-stage"
  role = data.aws_iam_role.lambda.arn
  handler = "salesforce-hourly_runner.handler"
  runtime = "nodejs12.x"
  source_code_hash = sha256(filebase64("salesforce-hourly_runner.js.zip"))
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

resource "aws_lambda_function" "update-salesforce-weekly-stage" {
  filename = "salesforce-weekly_runner.js.zip"
  function_name = "update-salesforce-weekly-stage"
  role = data.aws_iam_role.lambda.arn
  handler = "salesforce-weekly_runner.handler"
  runtime = "nodejs12.x"
  source_code_hash = sha256(filebase64("salesforce-weekly_runner.js.zip"))
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
    }
  }
}

resource "aws_lambda_function" "salesforce-api-stage" {
  filename = "salesforce-api_runner.js.zip"
  function_name = "salesforce-api-stage"
  role = data.aws_iam_role.lambda.arn
  handler = "salesforce-api_runner.handler"
  runtime = "nodejs12.x"
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
    }
  }
}

resource "aws_lambda_permission" "update-salesforce-hourly-stage" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update-salesforce-hourly-stage.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.update-salesforce-hourly-stage.arn
}

resource "aws_lambda_permission" "update-salesforce-weekly-stage" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update-salesforce-weekly-stage.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.update-salesforce-weekly-stage.arn
}

resource "aws_lambda_permission" "salesforce-api-stage" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.salesforce-api-stage.function_name
  principal = "events.amazonaws.com"
}
