resource "aws_elasticsearch_domain" "test" {
  domain_name           = "elasticsearch-test"
  elasticsearch_version = "7.10"
  cluster_config {
    instance_type = "m5.large.elasticsearch"
    instance_count = 1
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  ebs_options{
      ebs_enabled = true
      volume_type = "gp2"
      volume_size = 120
  }

  vpc_options {
    security_group_ids = [data.aws_security_group.datacite-private.id]
    subnet_ids = [data.aws_subnet.datacite-private.id]
  }

  cognito_options {
    enabled          = true
    identity_pool_id = aws_cognito_identity_pool.identity_pool.id
    role_arn         = data.aws_iam_role.CognitoAccessForAmazonES.arn
    user_pool_id     = data.aws_cognito_user_pools.user_pool.ids[0]
  }

  tags = {
    Domain = "elasticsearch-stage"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.elasticsearch-test.arn
    log_type                 = "SEARCH_SLOW_LOGS"
  }

  lifecycle {
    prevent_destroy = "true"
  }
}

resource "aws_cognito_user_pool_domain" "kibana-stage" {
  domain          = "datacite-stage"
  user_pool_id = data.aws_cognito_user_pools.user_pool.ids[0]
}

resource "aws_cognito_user_pool_client" "kibana_client" {
  name          = "kibana-client"
  user_pool_id  = data.aws_cognito_user_pools.user_pool.ids[0]
  callback_urls = ["https://${aws_elasticsearch_domain.test.kibana_endpoint}"]
  logout_urls   = ["https://${aws_elasticsearch_domain.test.kibana_endpoint}"]
}

resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name               = "kibana identity pool"
  allow_unauthenticated_identities = false
}

resource "aws_elasticsearch_domain_policy" "test" {
  domain_name = aws_elasticsearch_domain.test.domain_name

  access_policies = file("elasticsearch_policy.json")
}

resource "aws_cloudwatch_log_group" "elasticsearch-test" {
  name = "elasticsearch-test"
}

resource "aws_cloudwatch_log_resource_policy" "elasticsearch-test" {
  policy_name = "elasticsearch-test"
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

resource "aws_route53_record" "elasticsearch-test" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "elasticsearch.test.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [aws_elasticsearch_domain.test.endpoint]
}