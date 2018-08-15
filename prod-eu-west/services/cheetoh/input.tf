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

data "template_file" "cheetoh_task" {
  template = "${file("cheetoh.json")}"

  vars {
    api_url            = "${var.api_url}"
    secret_key_base    = "${var.secret_key_base}"
    bugsnag_key        = "${var.bugsnag_key}"
    memcache_servers   = "${var.memcache_servers}"
    admin_username     = "${var.admin_username}"
    admin_password     = "${var.admin_password}"
    version            = "${var.cheetoh_tags["version"]}"
  }
}
