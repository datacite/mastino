resource "aws_ecs_service" "queue-worker-test" {
  name            = "queue-worker-test"
  cluster         = data.aws_ecs_cluster.test.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.queue-worker-test.arn
  desired_count   = 10

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.queue-worker-test.arn
  }

}

resource "aws_cloudwatch_log_group" "queue-worker-test" {
  name = "/ecs/queue-worker-test"
}

resource "aws_ecs_task_definition" "queue-worker-test" {
  family                   = "queue-worker-test"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "4096"
  container_definitions = templatefile("queue-worker.json",
    {
      re3data_url                   = var.re3data_url
      bracco_url                    = var.bracco_url
      public_key                    = var.public_key
      jwt_public_key                = var.jwt_public_key
      jwt_private_key               = var.jwt_private_key
      session_encrypted_cookie_salt = var.session_encrypted_cookie_salt
      mysql_user                    = var.mysql_user
      mysql_password                = var.mysql_password
      mysql_database                = var.mysql_database
      mysql_host                    = var.mysql_host
      es_name                       = var.es_name
      es_host                       = var.es_host
      es_scheme                     = var.es_scheme
      es_port                       = var.es_port
      es_prefix                     = var.es_prefix
      elastic_password              = var.elastic_password
      handle_url                    = var.handle_url
      handle_username               = var.handle_username
      handle_password               = var.handle_password
      admin_username                = var.admin_username
      admin_password                = var.admin_password
      access_key                    = var.api_aws_access_key
      secret_key                    = var.api_aws_secret_key
      region                        = var.region
      s3_bucket                     = var.s3_bucket
      sentry_dsn                    = var.sentry_dsn
      mailgun_api_key               = var.mailgun_api_key
      memcache_servers              = var.memcache_servers
      jwt_blacklisted               = var.jwt_blacklisted
      slack_webhook_url             = var.slack_webhook_url
      version                       = var.lupo_tags["version"]
      sha                           = var.lupo_tags["sha"]
      shoryuken_concurrency         = var.shoryuken_concurrency
      metadata_storage_bucket_name  = var.metadata_storage_bucket_name
  })
}

resource "aws_service_discovery_service" "queue-worker-test" {
  name = "queue-worker.test"

  health_check_custom_config {
    failure_threshold = 3
  }

  dns_config {
    namespace_id = var.namespace_id

    dns_records {
      ttl  = 300
      type = "A"
    }
  }
}
