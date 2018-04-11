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

/* data "aws_lb_target_group" "profiles-stage" {
  name = "profiles-stage"
} */

data "template_file" "api_task" {
  template = "${file("api.json")}"

  vars {
    solr_url           = "${var.solr_url}"
    volpino_url        = "${var.volpino_url}"
    volpino_token      = "${var.volpino_token}"
    app_url            = "${var.app_url}"
    blog_url           = "${var.blog_url}"
    jwt_public_key     = "${var.jwt_public_key}"
    orcid_update_uuid  = "${var.orcid_update_uuid}"
    orcid_update_url   = "${var.orcid_update_url}"
    orcid_update_token = "${var.orcid_update_token}"
    github_personal_access_token = "${var.github_personal_access_token}"
    github_milestones_url = "${var.github_milestones_url}"
    github_issues_repo_url = "${var.github_issues_repo_url}"
    bugsnag_key        = "${var.bugsnag_key}"
    mailgun_api_key    = "${var.mailgun_api_key}"
    memcache_servers   = "${var.memcache_servers}"
    librato_email      = "${var.librato_email}"
    librato_token      = "${var.librato_token}"
    librato_suites     = "${var.librato_suites}"
    version            = "${var.spinone_tags["sha"]}"
  }
}
