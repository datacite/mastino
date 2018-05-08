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

data "template_file" "elastic-api_task" {
  template = "${file("elastic-api.json")}"

  vars {
    solr_url           = "${var.solr_url}"
    volpino_url        = "${var.volpino_url}"
    volpino_token      = "${var.volpino_token}"
    jwt_public_key     = "${var.jwt_public_key}"
    jwt_private_key    = "${var.jwt_private_key}"
    secret_key_base    = "${var.secret_key_base}"
    memcache_servers   = "${var.memcache_servers}"
    librato_email      = "${var.librato_email}"
    librato_token      = "${var.librato_token}"
    librato_suites     = "${var.librato_suites}"
    aws_access_key     = "${var.access_key}"
    aws_secret_key     = "${var.secret_key}"
    aws_region         = "${var.region}"
    es_host            = "${var.es_host}"
    app_url            = "${var.app_url}"
    version            = "${var.levriero_tags["sha"]}"
  }
}
