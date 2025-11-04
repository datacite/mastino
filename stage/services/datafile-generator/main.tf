resource "aws_ecs_task_definition" "datafile-generator-stage" {
  family = "datafile-generator-stage"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "16384"
  memory = "32768"
  container_definitions = templatefile("datafile-generator.json",
    {
      version          = var.alopekis_tags["sha"]
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

resource "aws_cloudwatch_log_group" "datafile-generator-stage" {
  name = "/ecs/datafile-generator-stage"
}

resource "aws_lambda_function" "datafile-generator-stage" {
  filename         = "datafile_generator.py.zip"
  function_name    = "datafile-generator-stage"
  role             = data.aws_iam_role.lambda.arn
  handler          = "datafile_generator.lambda_handler"
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
      AWS_CLUSTER        = data.aws_ecs_cluster.stage.id
      TASK_DEFINITION = "datafile-generator-stage"
    }
  }
}

resource "aws_s3_bucket" "datafile-stage" {
  bucket = var.datafile_bucket
  tags = {
    Environment = "stage"
    Name       = "Datafile storage"
  }
}

resource "aws_s3_bucket" "datafile-logs" {
  bucket = var.log_bucket
  tags = {
    Environment = "stage"
    Name       = "Datafile logs"
  }
}
