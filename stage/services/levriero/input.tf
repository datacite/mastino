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

data "template_file" "levriero_task" {
  template = "${file("levriero.json")}"

  vars {
    jwt_public_key     = "${var.jwt_public_key}"
    jwt_private_key    = "${var.jwt_private_key}"
    access_key         = "${var.access_key}"
    secret_key         = "${var.secret_key}"
    region             = "${var.region}"
    bugsnag_key        = "${var.bugsnag_key}"
    memcache_servers   = "${var.memcache_servers}"
    slack_webhook_url  = "${var.slack_webhook_url}"
    volpino_url        = "${var.volpino_url}"
    volpino_token      = "${var.volpino_token}"
    eventdata_url      = "${var.eventdata_url}"
    eventdata_token    = "${var.eventdata_token}"
    lagottino_url      = "${var.eventdata_url}"
    lagottino_token    = "${var.eventdata_token}"
    datacite_crossref_source_token = "${var.datacite_crossref_source_token}"
    datacite_related_source_token  = "${var.datacite_related_source_token}"
    datacite_other_source_token    = "${var.datacite_other_source_token}"
    version            = "${var.levriero_tags["sha"]}"
  }
}
