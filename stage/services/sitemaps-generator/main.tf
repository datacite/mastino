resource "aws_iam_role" "ecs_events" {
  name = "ecs_events"

  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
DOC
}

resource "aws_iam_role_policy" "ecs_events_run_task_with_any_role" {
  name = "ecs_events_run_task_with_any_role"
  role = aws_iam_role.ecs_events.id

  policy = <<DOC
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "ecs:RunTask",
            "Resource": "${replace(aws_ecs_task_definition.sitemaps-generator-stage.arn, "/:\\d+$/", ":*")}"
        }
    ]
}
DOC
}

resource "aws_cloudwatch_event_rule" "sitemaps-generator-stage" {
  name = "sitemaps-generator-stage"
  description = "Run sitemaps-generator-stage container via cron"
  schedule_expression = "cron(20 13 * * ? *)"
}

resource "aws_cloudwatch_event_target" "sitemaps-generator-stage" {
  target_id = "sitemaps-generator-stage"
  arn = data.aws_ecs_cluster.stage.arn
  rule = aws_cloudwatch_event_rule.sitemaps-generator-stage.name
  role_arn  = aws_iam_role.ecs_events.arn

  ecs_target {
    task_count          = 1
    launch_type         = "FARGATE"
    task_definition_arn = aws_ecs_task_definition.sitemaps-generator-stage.arn
    
    network_configuration {
      security_groups = [data.aws_security_group.datacite-private.id]
      subnets         = [
        data.aws_subnet.datacite-private.id,
        data.aws_subnet.datacite-alt.id
      ]
    }
  }
}

resource "aws_s3_bucket" "sitemaps-search-test" {
    bucket = "search.test.datacite.org"
    acl = "public-read"
    policy = templatefile("s3_public_read.json",
      {
        vpce_id = data.aws_vpc_endpoint.datacite.id,
        bucket_name = "search.test.datacite.org"
      })
    website {
        index_document = "index.html"
    }
    tags = {
      Name = "SitemapsSearchTest"
    }
}

resource "aws_cloudwatch_log_group" "sitemaps-generator-stage" {
  name = "/ecs/sitemaps-generator-stage"
}

resource "aws_ecs_task_definition" "sitemaps-generator-stage" {
  family = "sitemaps-generator-stage"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "1024"

  container_definitions =  templatefile("sitemaps-generator.json",
    {
      access_key  = var.access_key,
      secret_key  = var.secret_key,
      region      = var.region
    })
}
