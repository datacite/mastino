# resource "aws_cloudwatch_event_rule" "sitemaps-generator" {
#   name = "sitemaps-generator"
#   description = "Run sitemaps-generator container via cron"
#   schedule_expression = "cron(50 9 ? * MON *)"
# }

resource "aws_cloudwatch_event_target" "sitemaps-generator" {
  target_id = "sitemaps-generator"
  arn       = data.aws_ecs_cluster.default.arn
  rule      = aws_cloudwatch_event_rule.sitemaps-generator.name
  role_arn  = data.aws_iam_role.ecs_events.arn

  ecs_target {
    task_count          = 1
    launch_type         = "FARGATE"
    task_definition_arn = aws_ecs_task_definition.sitemaps-generator.arn

    network_configuration {
      security_groups = [data.aws_security_group.datacite-private.id]
      subnets = [
        data.aws_subnet.datacite-private.id,
        data.aws_subnet.datacite-alt.id
      ]
    }
  }
}

resource "aws_s3_bucket" "akita" {
  bucket = "commons.datacite.org"
  acl    = "public-read"
  policy = templatefile("s3_public_read.json",
    {
      vpce_id     = data.aws_vpc_endpoint.datacite.id
      bucket_name = "commons.datacite.org"
  })
  website {
    index_document = "index.html"
  }
  tags = {
    Name = "Commons"
  }
}

resource "aws_cloudwatch_log_group" "sitemaps-generator" {
  name = "/ecs/sitemaps-generator"
}

resource "aws_ecs_task_definition" "sitemaps-generator" {
  family                   = "sitemaps-generator"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "2048"

  container_definitions = templatefile("sitemaps-generator.json",
    {
      access_key        = var.access_key,
      secret_key        = var.secret_key,
      region            = var.region,
      slack_webhook_url = var.slack_webhook_url
  })
}
