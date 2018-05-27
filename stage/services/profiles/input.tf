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

data "aws_ecs_cluster" "stage" {
  cluster_name = "stage"
}

data "aws_iam_role" "ecs_service" {
  name = "ecs_service"
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
    jwt_private_key    = "${var.jwt_private_key}"
    jwt_public_key     = "${var.jwt_public_key}"
    github_personal_access_token = "${var.github_personal_access_token}"
    bugsnag_key        = "${var.bugsnag_key}"
    bugsnag_js_key     = "${var.bugsnag_js_key}"
    orcid_api_url      = "${var.orcid_api_url}"
    orcid_update_uuid  = "${var.orcid_update_uuid}"
    orcid_url          = "${var.orcid_url}"
    orcid_token        = "${var.orcid_token}"
    search_url         = "${var.search_url}"
    solr_url           = "${var.solr_url}"
    blog_url           = "${var.blog_url}"
    mysql_user         = "${var.mysql_user}"
    mysql_password     = "${var.mysql_password}"
    mysql_database     = "${var.mysql_database}"
    mysql_host         = "${var.mysql_host}"
    app_url            = "${var.app_url}"
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
    librato_email      = "${var.librato_email}"
    librato_token      = "${var.librato_token}"
    librato_suites     = "${var.librato_suites}"
    version            = "${var.volpino_tags["sha"]}"
  }
}
