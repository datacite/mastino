provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
  version    = "~> 1.6"
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

data "aws_lb_target_group" "solr-stage" {
  name = "solr-stage"
}

data "aws_vpc_endpoint" "datacite" {
  vpc_id       = "${var.vpc_id}"
  service_name = "com.amazonaws.eu-west-1.s3"
}

data "template_file" "search-stage" {
    template = "${file("s3_public_read.json")}"

    vars {
        vpce_id = "${data.aws_vpc_endpoint.datacite.id}"
        bucket_name = "${aws_route53_record.search-stage.name}"
    }
}

data "template_file" "search_stage_task" {
  template = "${file("search.json")}"

  vars {
    jwt_public_key     = "${var.jwt_public_key}"
    orcid_update_uuid  = "${var.orcid_update_uuid}"
    orcid_update_url   = "${var.orcid_update_url}"
    orcid_update_token = "${var.orcid_update_token}"
    orcid_url          = "${var.orcid_url}"
    api_url            = "${var.api_url}"
    data_url           = "${var.data_url}"
    cdn_url            = "${var.cdn_url}"
    secret_key_base    = "${var.secret_key_base}"
    memcache_servers   = "${var.memcache_servers}"
    bugsnag_key        = "${var.bugsnag_key}"
    bugsnag_js_key     = "${var.bugsnag_js_key}"
    gabba_cookie       = "${var.gabba_cookie}"
    gabba_url          = "${var.gabba_url}"
    version            = "${var.doi-metadata-search_tags["sha"]}"
  }
}
