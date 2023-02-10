provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
  version    = "~> 2.70"
}

data "aws_route53_zone" "production" {
  name = "datacite.org"
}

data "aws_route53_zone" "internal" {
  name = "datacite.org"
  private_zone = true
}

data "aws_security_group" "datacite-private" {
  id = var.security_group_id
}

data "aws_subnet" "datacite-private" {
  id = var.subnet_datacite-private_id
}

data "aws_subnet" "datacite-alt" {
  id = var.subnet_datacite-alt_id
}

data "aws_ecs_cluster" "stage" {
  cluster_name = "stage"
}

data "aws_iam_role" "ecs_service" {
  name = "ecs_service"
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

data "aws_lb" "stage" {
  name = var.lb_name
}

data "aws_lb_listener" "stage" {
  load_balancer_arn = data.aws_lb.stage.arn
  port = 443
}

data "template_file" "analytics_task" {
  template = file("analytics.json")

  vars = {
    access_key               = var.access_key
    secret_key               = var.secret_key
    region                   = var.region
    slack_webhook_url        = var.slack_webhook_url
    version                  = var.analytics_tags["sha"]
    smtp_host_port           = var.smtp_host_port
    clickhouse_database_url  = var.clickhouse_database_url
    clickhouse_database_user = var.clickhouse_database_user
    clickhouse_database_password = var.clickhouse_database_password
    admin_user_email         = var.admin_user_email
    smtp_retries             = var.smtp_retries
    smtp_host_ssl_enabled    = var.smtp_host_ssl_enabled
    mailer_adapter           = var.mailer_adapter
    database_url             = var.database_url
    postmark_api_key         = var.postmark_api_key
    smtp_user_pwd            = var.smtp_user_pwd
    admin_user_pwd           = var.admin_user_pwd
    smtp_host_addr           = var.smtp_host_addr
    admin_user_name          = var.admin_user_name
    base_url                 = var.base_url
    mailer_email             = var.mailer_email
    secret_key_base          = var.secret_key_base
    smtp_user_name           = var.smtp_user_name
    public_key               = var.public_key
  }
}
