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

data "aws_security_group" "datacite-private" {
  id = "${var.security_group_id}"
}

 data "aws_subnet" "datacite-private" {
  id = "${var.subnet_datacite-private_id}"
}

 data "aws_subnet" "datacite-alt" {
  id = "${var.subnet_datacite-alt_id}"
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

data "template_file" "resolution-logs-pipeline_task" {
  template = "${file("resolution-logs-pipeline.json")}"

  vars {
    public_key         = "${var.public_key}"
    jwt_public_key     = "${var.jwt_public_key}"
    jwt_private_key    = "${var.jwt_private_key}"
    access_key         = "${var.access_key}"
    secret_key         = "${var.secret_key}"
    region             = "${var.region}"
    s3_bucket          = "${var.s3_bucket}"
    bugsnag_key        = "${var.bugsnag_key}"
    es_host            = "${var.es_host}"
    es_index           = "${var.es_index}"
    es_name            = "${var.es_name}"
    s3_resolution_logs_bucket   = "${var.s3_resolution_logs_bucket}"
    s3_merged_logs_bucket       = "${var.s3_merged_logs_bucket}"
    version            = "${var.shiba-inu_tags["sha"]}"
  }
}