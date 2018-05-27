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

data "template_file" "eventdata_task" {
  template = "${file("eventdata.json")}"

  vars {
    jwt_public_key     = "${var.jwt_public_key}"
    jwt_private_key    = "${var.jwt_private_key}"
    mysql_user         = "${var.mysql_user}"
    mysql_password     = "${var.mysql_password}"
    mysql_database     = "${var.mysql_database}"
    mysql_host         = "${var.mysql_host}"
    access_key         = "${var.access_key}"
    secret_key         = "${var.secret_key}"
    region             = "${var.region}"
    s3_bucket          = "${var.s3_bucket}"
    bugsnag_key        = "${var.bugsnag_key}"
    mailgun_api_key    = "${var.mailgun_api_key}"
    memcache_servers   = "${var.memcache_servers}"
    librato_email      = "${var.librato_email}"
    librato_token      = "${var.librato_token}"
    librato_suites     = "${var.librato_suites}"
    slack_webhook_url  = "${var.slack_webhook_url}"
    version            = "${var.lagottino_tags["version"]}"
  }
}
