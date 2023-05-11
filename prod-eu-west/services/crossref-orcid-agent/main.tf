# crossref-orcid-agent lambda function is scheduled never to run to intentionally disable the crossref-orcid-agent import in levriero

resource "aws_cloudwatch_event_rule" "crossref-orcid-agent" {
  name = "crossref-orcid-agent"
  description = "Trigger crossref-orcid agent via cron"
  schedule_expression = "cron(0 0 1 1 ? 1970)"
}

resource "aws_cloudwatch_event_target" "crossref-orcid-agent" {
  target_id = "crossref-orcid-agent"
  rule = aws_cloudwatch_event_rule.crossref-orcid-agent.name
  arn = aws_lambda_function.crossref-orcid-agent.arn
}

resource "aws_lambda_function" "crossref-orcid-agent" {
  filename = "crossref-orcid-agent_runner.js.zip"
  function_name = "crossref-orcid-agent"
  role = data.aws_iam_role.lambda.arn
  handler = "crossref-orcid-agent_runner.handler"
  runtime = "nodejs14.x"
  source_code_hash = sha256(filebase64("crossref-orcid-agent_runner.js.zip"))
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

resource "aws_lambda_permission" "crossref-orcid-agent" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.crossref-orcid-agent.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.crossref-orcid-agent.arn
}
