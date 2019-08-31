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
  name = "${var.lb_name}"
}

data "aws_lb_listener" "stage" {
  load_balancer_arn = "${data.aws_lb.stage.arn}"
  port = 443
}

data "template_file" "profiles_task" {
  template = "${file("profiles.json")}"

  vars {
    redis_url          = "${var.redis_url}"
    bracco_url         = "${var.bracco_url}"
    public_key         = "${var.public_key}"
    jwt_private_key    = "${var.jwt_private_key}"
    jwt_public_key     = "${var.jwt_public_key}"
    github_personal_access_token = "${var.github_personal_access_token}"
    sentry_dsn         = "${var.sentry_dsn}"
    orcid_api_url      = "${var.orcid_api_url}"
    orcid_update_uuid  = "${var.orcid_update_uuid}"
    orcid_url          = "${var.orcid_url}"
    orcid_token        = "${var.orcid_token}"
    search_url         = "${var.search_url}"
    blog_url           = "${var.blog_url}"
    mysql_user         = "${var.mysql_user}"
    mysql_password     = "${var.mysql_password}"
    mysql_database     = "${var.mysql_database}"
    mysql_host         = "${var.mysql_host}"
    api_url            = "${var.api_url}"
    cdn_url            = "${var.cdn_url}"
    secret_key_base    = "${var.secret_key_base}"
    orcid_client_id    = "${var.orcid_client_id}"
    orcid_client_secret = "${var.orcid_client_secret}"
    github_client_id   = "${var.github_client_id}"
    github_client_secret = "${var.github_client_secret}"
    google_client_id   = "${var.google_client_id}"
    google_client_secret = "${var.google_client_secret}"
    notification_access_token = "${var.notification_access_token}"
    memcache_servers   = "${var.memcache_servers}"
    access_key         = "${var.access_key}"
    secret_key         = "${var.secret_key}"
    region             = "${var.region}"
    s3_bucket          = "${var.s3_bucket}"
    version            = "${var.volpino_tags["sha"]}"
  }
}
