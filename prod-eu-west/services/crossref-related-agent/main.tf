# crossref-related-agent lambda function is scheduled never to run to intentionally disable the crossref-related-agent import in levriero

resource "aws_cloudwatch_event_rule" "crossref-related-agent" {
  name = "crossref-related-agent"
  description = "Trigger crossref-related agent via cron"
  schedule_expression = "cron(0 0 1 1 ? 1970)"
}

resource "aws_cloudwatch_event_target" "crossref-related-agent" {
  target_id = "crossref-related-agent"
  rule = aws_cloudwatch_event_rule.crossref-related-agent.name
  arn = aws_lambda_function.crossref-related-agent.arn
}

resource "aws_lambda_function" "crossref-related-agent" {
  filename = "crossref-related-agent_runner.js.zip"
  function_name = "crossref-related-agent"
  role = data.aws_iam_role.lambda.arn
  handler = "crossref-related-agent_runner.handler"
  runtime = "nodejs14.x"
  source_code_hash = sha256(filebase64("crossref-related-agent_runner.js.zip"))
  timeout = "270"

  vpc_config {
    subnet_ids = [data.aws_subnet.datacite-private.id, data.aws_subnet.datacite-alt.id]
    security_group_ids = [data.aws_security_group.datacite-private.id]
  }
  environment {
    variables = {
      host     = var.host
      token    = var.token
    }
  }
}

resource "aws_lambda_permission" "crossref-related-agent" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.crossref-related-agent.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.crossref-related-agent.arn
}
