provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "aws_route53_zone" "production" {
  name = "datacite.org"
}

data "aws_route53_zone" "internal" {
  name = "datacite.org"
  private_zone = true
}

data "aws_security_group" "datacite-private" {
  id = "${var.security_group_id}"
}

data "aws_subnet" "datacite-private" {
  id = "${var.subnet_datacite-private_id}"
}

data "aws_subnet" "datacite-alt" {
  id = "${var.subnet_datacite-alt_id}"
}

data "aws_ecs_cluster" "default" {
  cluster_name = "default"
}

data "aws_iam_role" "ecs_service" {
  name = "ecs_service"
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

data "aws_lb" "default" {
  name = "${var.lb_name}"
}

data "aws_lb_listener" "default" {
  load_balancer_arn = "${data.aws_lb.default.arn}"
  port = 443
}

data "template_file" "client-api_task" {
  template = "${file("client-api.json")}"

  vars {
    re3data_url        = "${var.re3data_url}"
    bracco_url         = "${var.bracco_url}"
    jwt_public_key     = "${var.jwt_public_key}"
    jwt_private_key    = "${var.jwt_private_key}"
    session_encrypted_cookie_salt = "${var.session_encrypted_cookie_salt}"
    handle_url         = "${var.handle_url}"
    handle_username    = "${var.handle_username}"
    handle_password    = "${var.handle_password}"
    mysql_user         = "${var.mysql_user}"
    mysql_password     = "${var.mysql_password}"
    mysql_database     = "${var.mysql_database}"
    mysql_host         = "${var.mysql_host}"
    es_name            = "${var.es_name}"
    es_host            = "${var.es_host}"
    public_key         = "${var.public_key}"
    access_key         = "${var.access_key}"
    secret_key         = "${var.secret_key}"
    region             = "${var.region}"
    s3_bucket          = "${var.s3_bucket}"
    admin_username     = "${var.admin_username}"
    admin_password     = "${var.admin_password}"
    bugsnag_key        = "${var.bugsnag_key}"
    mailgun_api_key    = "${var.mailgun_api_key}"
    memcache_servers   = "${var.memcache_servers}"
    slack_webhook_url  = "${var.slack_webhook_url}"
    version            = "${var.lupo_tags["version"]}"
  }
}
