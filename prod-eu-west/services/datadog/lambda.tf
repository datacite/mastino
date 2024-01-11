
# This lambda function is used to forward logs from CloudWatch to Datadog
# We're using a manual lambda function (as opposed to CloudFormation) to keep everything here in the mastino repo
# The source code is directly provided by DataDog from their latest releases
# To update you will need to replace the filename and source_code_hash
resource "aws_lambda_function" "logs" {
  filename = "aws-dd-forwarder-3.100.0.zip"
  function_name = "logs"
  role = data.aws_iam_role.lambda.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.11"
  source_code_hash = sha256(filebase64("aws-dd-forwarder-3.100.0.zip"))
  timeout = "120"
  memory_size = "1024"

  vpc_config {
    subnet_ids = [data.aws_subnet.datacite-private.id, data.aws_subnet.datacite-alt.id]
    security_group_ids = [data.aws_security_group.datacite-private.id]
  }
  environment {
    variables = {
      DD_API_KEY = var.dd_api_key
      DD_ENHANCED_METRICS = "false" # We don't want lambda enhanced metrics for the log forwarder itself
    }
  }
}
