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

data "template_file" "metrics-api_task" {
  template = "${file("metrics-api.json")}"

  vars {
    public_key         = "${var.public_key}"
    jwt_public_key     = "${var.jwt_public_key}"
    jwt_private_key    = "${var.jwt_private_key}"
    memcache_servers   = "${var.memcache_servers}"
    access_key         = "${var.access_key}"
    secret_key         = "${var.secret_key}"
    region             = "${var.region}"
    s3_bucket          = "${var.s3_bucket}"
    mysql_database     = "${var.mysql_database}"
    mysql_user         = "${var.mysql_user}"
    mysql_password     = "${var.mysql_password}"
    mysql_host         = "${var.mysql_host}"
    usage_url          = "${var.usage_url}"
    sentry_dsn         = "${var.sentry_dsn}"
    rack_timeout_service_timeout = "${var.rack_timeout_service_timeout}"
    version            = "${var.sashimi_tags["version"]}"
  }
}