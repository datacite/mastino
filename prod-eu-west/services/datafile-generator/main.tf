resource "aws_ecs_task_definition" "datafile-generator" {
  family = "datafile-generator"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "16384"
  memory = "32768"
  task_role_arn = data.aws_iam_role.container_role.arn
  ephemeral_storage {
    size_in_gib = 200
  }
  container_definitions = templatefile("datafile-generator.json",
    {
      version          = var.alopekis_tags["version"]
      opensearch_host  = var.opensearch_host
      opensearch_port  = var.opensearch_port
      opensearch_index = var.opensearch_index
      output_path      = var.output_path
      workers          = var.workers
      datafile_bucket  = var.datafile_bucket
      log_bucket       = var.log_bucket
      access_key       = var.alopekis_aws_access_key
      secret_key       = var.alopekis_aws_secret_key
      region           = var.region
    })
}

resource "aws_cloudwatch_log_group" "datafile-generator" {
  name = "/ecs/datafile-generator"
}

resource "aws_lambda_function" "datafile-generator" {
  filename         = "datafile_generator.py.zip"
  function_name    = "datafile-generator"
  role             = data.aws_iam_role.lambda.arn
  handler          = "datafile_generator_runner.lambda_handler"
  runtime          = "python3.10"
  source_code_hash = sha256(filebase64("datafile_generator.py.zip"))
  timeout          = "30"

  vpc_config {
    subnet_ids         = [data.aws_subnet.datacite-private.id, data.aws_subnet.datacite-alt.id]
    security_group_ids = [data.aws_security_group.datacite-private.id]
  }

  environment {
    variables = {
      AWS_SECURITY_GROUP = data.aws_security_group.datacite-private.id
      AWS_DATACITE_SUBNET_PRIVATE       = data.aws_subnet.datacite-private.id
      AWS_DATACITE_SUBNET_ALT       = data.aws_subnet.datacite-alt.id
      AWS_CLUSTER        = data.aws_ecs_cluster.default.id
      TASK_DEFINITION = "datafile-generator"
    }
  }
}

import {
  to = aws_s3_bucket.datafile-logs
  id = "datafile-logs"
}

resource "aws_s3_bucket" "datafile" {
  bucket = var.datafile_bucket
  tags = {
    Environment = "production"
    Name       = "Datafile storage"
  }
}

resource "aws_s3_bucket" "datafile-logs" {
  bucket = var.log_bucket
  tags = {
    Name       = "Datafile logs"
  }
}

# resource "aws_cloudwatch_event_rule" "datafile-generator-cron" {
#   name                = "datafile-generator-cron"
#   description         = "Run adata file generator via cron"
#   schedule_expression = "cron(00 0 1 * *)" # 1st day of the month at midnight
# }
#
# resource "aws_cloudwatch_event_target" "datafile-generator-cron" {
#   target_id = "datafile-generator-cron"
#   rule      = aws_cloudwatch_event_rule.datafile-generator-cron.name
#   arn       = aws_lambda_function.datafile-generator.arn
# }
#
# resource "aws_lambda_permission" "datafile-generator-cron" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.datafile-generator.function_name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.datafile-generator-cron.arn
# }