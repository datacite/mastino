resource "aws_ecs_task_definition" "analytics-worker-stage" {
  family = "analytics-worker-stage"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"
  container_definitions = templatefile("analytics-worker.json",
    {
      version            = var.keeshond_tags["sha"]
      analytics_database_dbname    = var.analytics_database_dbname
      analytics_database_host      = var.analytics_database_host
      analytics_database_user      = var.analytics_database_user
      analytics_database_password  = var.analytics_database_password
      datacite_jwt = var.datacite_jwt
    })
}

resource "aws_cloudwatch_log_group" "analytics-worker-stage" {
  name = "/ecs/analytics-worker-stage"
}

resource "aws_lambda_function" "analytics-worker-stage" {
  filename         = "analytics_worker.py.zip"
  function_name    = "analytics-worker-stage"
  role             = data.aws_iam_role.lambda.arn
  handler          = "analytics_worker_runner.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = sha256(filebase64("analytics_worker.py.zip"))
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
      AWS_CLUSTER        = data.aws_ecs_cluster.stage.id
      TASK_DEFINITION = "analytics-worker-stage"
    }
  }
}

resource "aws_lambda_event_source_mapping" "analytics_stage_event_source_mapping" {
  event_source_arn = data.aws_sqs_queue.analytics.arn
  enabled          = true
  function_name    = aws_lambda_function.analytics-worker-stage.arn
  batch_size       = 1
}

resource "aws_lambda_function" "analytics_stage_queue_reports" {
  filename         = "analytics_queue_reports.py.zip"
  function_name    = "analytics-queue-reports-stage"
  role             = data.aws_iam_role.lambda.arn
  handler          = "analytic_queue_reports_runner.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = sha256(filebase64("analytics_queue_reports.py.zip"))
  timeout          = "30"

  vpc_config {
    subnet_ids         = [data.aws_subnet.datacite-private.id, data.aws_subnet.datacite-alt.id]
    security_group_ids = [data.aws_security_group.datacite-private.id]
  }

  environment {
    variables = {
        DATACITE_API_URL = var.datacite_api_url
        API_USERNAME = var.api_username
        API_PASSWORD = var.api_password
        QUEUE_NAME = var.analytics_queue
    }
  }
}

# resource "aws_lambda_permission" "analytics-worker-stage" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.analytics-worker-stage.function_name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.analytics-worker-stage.arn
# }