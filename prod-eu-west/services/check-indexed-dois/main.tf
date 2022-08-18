# resource "aws_cloudwatch_event_rule" "check-indexed-dois" {
#   name = "check-indexed-dois"
#   description = "Run check-indexed-dois API call via cron"
#   schedule_expression = "cron(15 4 ? * MON *)"
# }

# resource "aws_cloudwatch_event_target" "check-indexed-dois" {
#   target_id = "check-indexed-dois"
#   rule = aws_cloudwatch_event_rule.check-indexed-dois.name
#   arn = aws_lambda_function.check-indexed-dois.arn
# }

# resource "aws_lambda_function" "check-indexed-dois" {
#   filename = "check-indexed-dois_runner.js.zip"
#   function_name = "check-indexed-dois"
#   role = data.aws_iam_role.lambda.arn
#   handler = "check-indexed-dois_runner.handler"
#   runtime = "nodejs12.x"
#   source_code_hash = sha256(filebase64("check-indexed-dois_runner.js.zip"))
#   timeout = "270"

#   vpc_config {
#     subnet_ids = [data.aws_subnet.datacite-private.id, data.aws_subnet.datacite-alt.id]
#     security_group_ids = [data.aws_security_group.datacite-private.id]
#   }
#   environment {
#     variables = {
#       host     = var.host
#       username = var.username
#       password = var.password
#     }
#   }
# }

# resource "aws_lambda_permission" "check-indexed-dois" {
#   statement_id = "AllowExecutionFromCloudWatch"
#   action = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.check-indexed-dois.function_name
#   principal = "events.amazonaws.com"
#   source_arn = aws_cloudwatch_event_rule.check-indexed-dois.arn
# }
