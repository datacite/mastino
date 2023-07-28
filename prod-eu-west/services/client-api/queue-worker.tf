resource "aws_ecs_service" "queue-worker" {
  name = "queue-worker"
  cluster = data.aws_ecs_cluster.default.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.queue-worker.arn
  desired_count = 2

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = ["desired_count"]
  }

  network_configuration {
    security_groups = [data.aws_security_group.datacite-private.id]
    subnets         = [
      data.aws_subnet.datacite-private.id,
      data.aws_subnet.datacite-alt.id
    ]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.queue-worker.arn
  }

}

resource "aws_cloudwatch_log_group" "queue-worker" {
  name = "/ecs/queue-worker"
}

resource "aws_ecs_task_definition" "queue-worker" {
  family = "queue-worker"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "2048"
  memory = "8192"
  container_definitions = templatefile("queue-worker.json",
    {
      re3data_url        = var.re3data_url
      api_url            = var.api_url
      bracco_url         = var.bracco_url
      jwt_public_key     = var.jwt_public_key
      jwt_private_key    = var.jwt_private_key
      session_encrypted_cookie_salt = var.session_encrypted_cookie_salt
      handle_url         = var.handle_url
      handle_username    = var.handle_username
      handle_password    = var.handle_password
      mysql_user         = var.mysql_user
      mysql_password     = var.mysql_password
      mysql_database     = var.mysql_database
      mysql_host         = var.mysql_host
      es_name            = var.es_name
      es_host            = var.es_host
      public_key         = var.public_key
      access_key         = var.access_key
      secret_key         = var.secret_key
      region             = var.region
      s3_bucket          = var.s3_bucket
      admin_username     = var.admin_username
      admin_password     = var.admin_password
      sentry_dsn         = var.sentry_dsn
      mailgun_api_key    = var.mailgun_api_key
      memcache_servers   = var.memcache_servers
      slack_webhook_url  = var.slack_webhook_url
      jwt_blacklisted    = var.jwt_blacklisted
      version            = var.lupo_tags["version"]
      plugin_openapi_url  = var.plugin_openapi_url
      plugin_manifest_url = var.plugin_manifest_url
    })
}

resource "aws_service_discovery_service" "queue-worker" {
  name = "queue-worker"

  health_check_custom_config {
    failure_threshold = 3
  }

  dns_config {
    namespace_id = var.namespace_id

    dns_records {
      ttl = 300
      type = "A"
    }
  }
}