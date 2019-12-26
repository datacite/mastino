resource "aws_cloudwatch_event_rule" "datafiles-generator-stage" {
  name = "datafiles-generator-stage"
  description = "Run datafiles-generator-stage container via cron"
  // schedule_expression = "cron(15 4 1 10 ? *)"
  schedule_expression = "cron(15 4 1 10 ? *)"
}

resource "aws_cloudwatch_event_target" "datafiles-generator-stage" {
  target_id = "datafiles-generator-stage"
  arn = data.aws_ecs_cluster.stage.arn
  rule = aws_cloudwatch_event_rule.datafiles-generator-stage.name
  role_arn  = data.aws_iam_role.ecs_events-stage.arn

  ecs_target {
    task_count          = 1
    launch_type         = "FARGATE"
    task_definition_arn = aws_ecs_task_definition.datafiles-generator-stage.arn
    
    network_configuration {
      security_groups = [data.aws_security_group.datacite-private.id]
      subnets         = [
        data.aws_subnet.datacite-private.id,
        data.aws_subnet.datacite-alt.id
      ]
    }
  }
}

resource "aws_s3_bucket" "datafiles-test" {
    bucket = "datafiles.test.datacite.org"
    acl = "public-read"
    policy = templatefile("s3_public_read.json",
      {
        vpce_id = data.aws_vpc_endpoint.datacite.id,
        bucket_name = "datafiles.test.datacite.org"
      })
    website {
        index_document = "index.html"
    }
    tags = {
      Name = "datafilesTest"
    }
}

resource "aws_cloudwatch_log_group" "datafiles-generator-stage" {
  name = "/ecs/datafiles-generator-stage"
}

resource "aws_ecs_task_definition" "datafiles-generator-stage" {
  family = "datafiles-generator-stage"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "1024"

  container_definitions =  templatefile("datafiles-generator.json",
    {
      access_key  = var.access_key,
      secret_key  = var.secret_key,
      region      = var.region,
      slack_webhook_url = var.slack_webhook_url
    })
}
