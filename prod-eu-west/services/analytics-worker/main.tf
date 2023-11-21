resource "aws_ecs_task_definition" "analytics-worker" {
  family = "analytics-worker"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"
  container_definitions = templatefile("analytics-worker.json",
    {
      version            = var.keeshond_tags["version"]
      datacite_api_url   = var.datacite_api_url
      analytics_database_dbname    = var.analytics_database_dbname
      analytics_database_host      = var.analytics_database_host
      analytics_database_user      = var.analytics_database_user
      analytics_database_password  = var.analytics_database_password
      datacite_jwt = var.datacite_jwt
    })
}

resource "aws_cloudwatch_log_group" "analytics-worker" {
  name = "/ecs/analytics-worker"
}

resource "aws_lambda_function" "analytics-worker" {
  filename         = "analytics_worker.py.zip"
  function_name    = "analytics-worker"
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
      AWS_CLUSTER        = data.aws_ecs_cluster.default.id
      TASK_DEFINITION = "analytics-worker"
    }
  }
}

resource "aws_lambda_event_source_mapping" "analytics_event_source_mapping" {
  event_source_arn = data.aws_sqs_queue.analytics.arn
  enabled          = true
  function_name    = aws_lambda_function.analytics-worker.arn
  batch_size       = 10
}

resource "aws_lambda_function" "analytics-queue-reports" {
  filename         = "analytics_queue_reports.py.zip"
  function_name    = "analytics-queue_reports"
  role             = data.aws_iam_role.lambda.arn
  handler          = "analytics_queue_reports_runner.lambda_handler"
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
        BLOCKED_REPOSITORIES = var.blocked_repositories
    }
  }
}

resource "aws_cloudwatch_event_rule" "analytics-queue-reports" {
  name                = "analytics-queue-reports"
  description         = "Run analytics-queue-reports via cron"
  schedule_expression = "cron(00 1 1 * ? *)" # 1st day of the month at 1am
}

resource "aws_cloudwatch_event_target" "analytics-queue-reports" {
  target_id = "analytics-queue-reports"
  rule      = aws_cloudwatch_event_rule.analytics-queue-reports.name
  arn       = aws_lambda_function.analytics-queue-reports.arn
}

resource "aws_lambda_permission" "analytics-queue-reports" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.analytics-queue-reports.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.analytics-queue-reports.arn
}