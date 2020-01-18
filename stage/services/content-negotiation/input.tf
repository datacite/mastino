provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "aws_route53_zone" "crosscite" {
  name = "crosscite.org"
}

data "aws_route53_zone" "production" {
  name = "datacite.org"
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

data "aws_lb" "crosscite-stage" {
  name = "${var.lb_name}"
}

data "aws_lb" "stage" {
  name = "${var.lb_name}"
}

data "aws_lb_listener" "crosscite-stage" {
  load_balancer_arn = "${data.aws_lb.crosscite-stage.arn}"
  port = 443
}

data "aws_lb_listener" "stage" {
  load_balancer_arn = "${data.aws_lb.stage.arn}"
  port = 443
}

data "aws_lb_target_group" "content-negotiation-stage" {
  name = "content-negotiation-stage"
}

data "template_file" "content-negotiation_task" {
  template = "${file("content-negotiation.json")}"

  vars {
    sentry_dsn         = "${var.sentry_dsn}"
    memcache_servers   = "${var.memcache_servers}"
    api_url            = "${var.api_url}"
    public_key         = "${var.public_key}"
    version            = "${var.content-negotiation_tags["sha"]}"
  }
}
