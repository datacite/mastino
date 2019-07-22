provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "aws_route53_zone" "crosscite" {
  name = "crosscite.org"
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

data "aws_ecs_cluster" "crosscite-stage" {
  cluster_name = "crosscite-stage"
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

data "aws_lb_listener" "crosscite-stage" {
  load_balancer_arn = "${data.aws_lb.crosscite-stage.arn}"
  port = 443
}

data "template_file" "content-negotiation_task" {
  template = "${file("content-negotiation.json")}"

  vars {
    sentry_dsn         = "${var.sentry_dsn}"
    ssh_public_key     = "${var.ssh_public_key}"
    memcache_servers   = "${var.memcache_servers}"
    version            = "${var.content-negotiation_tags["sha"]}"
  }
}
