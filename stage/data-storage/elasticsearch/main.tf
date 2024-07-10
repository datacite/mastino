resource "aws_elasticsearch_domain" "stage" {
  domain_name           = "elasticsearch-stage"
  elasticsearch_version = "OpenSearch_2.13"
  cluster_config {
    instance_type = "t3.medium.elasticsearch"
    instance_count = 1
  }

  advanced_options = {
    "override_main_response_version" = "true"
    "rest.action.multi.allow_explicit_index" = "true"
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  ebs_options{
      ebs_enabled = true
      volume_type = "gp3"
      volume_size = 60
  }

  vpc_options {
    security_group_ids = [data.aws_security_group.datacite-private.id]
    subnet_ids = [data.aws_subnet.datacite-private.id]
  }

  tags = {
    Domain = "elasticsearch-stage"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.elasticsearch-stage.arn
    log_type                 = "SEARCH_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.elasticsearch-stage.arn
    log_type                 = "ES_APPLICATION_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.elasticsearch-stage.arn
    log_type                 = "INDEX_SLOW_LOGS"
  }

  lifecycle {
    prevent_destroy = "true"
  }
}

resource "aws_elasticsearch_domain_policy" "stage" {
  domain_name = aws_elasticsearch_domain.stage.domain_name

  access_policies = file("elasticsearch_policy.json")
}

resource "aws_cloudwatch_log_group" "elasticsearch-stage" {
  name = "elasticsearch-stage"
}

resource "aws_cloudwatch_log_resource_policy" "elasticsearch-stage" {
  policy_name = "elasticsearch-stage"
  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}

resource "aws_route53_record" "elasticsearch-stage" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "elasticsearch.stage.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [aws_elasticsearch_domain.stage.endpoint]
}
