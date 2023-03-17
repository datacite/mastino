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
  timeout          = "270"

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