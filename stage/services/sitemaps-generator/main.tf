module "fargate-scheduled-task" {
  source  = "baikonur-oss/fargate-scheduled-task/aws"
  version = "v2.0.1"

  execution_role_arn  = data.aws_iam_role.ecs_task_execution_role.arn
  name                = "sitemaps-generator-test"
  schedule_expression = "cron(55 11 * * ? *)"
  is_enabled          = "true"

  target_cluster_arn = data.aws_ecs_cluster.stage.arn

  task_definition_arn = aws_ecs_task_definition.sitemaps-generator-test.arn
  task_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  task_count          = 1

  subnet_ids = [data.aws_subnet.datacite-private.id, data.aws_subnet.datacite-alt.id]
  security_group_ids = [data.aws_security_group.datacite-private.id]
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

resource "aws_ecs_task_definition" "sitemaps-generator-test" {
  family = "sitemaps-generator-test"
  container_definitions =  templatefile("sitemaps-generator.json",
    {
      access_key  = var.access_key,
      secret_key  = var.secret_key,
      region      = var.region
    })
}
