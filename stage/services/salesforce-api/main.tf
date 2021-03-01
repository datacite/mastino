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
    }
  }
}

resource "aws_lambda_permission" "salesforce-api-stage" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.salesforce-api-stage.function_name
  principal = "events.amazonaws.com"
}
