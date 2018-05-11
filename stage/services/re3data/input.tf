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

data "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"
}

data "aws_lb" "stage" {
  name = "${var.lb_name}"
}

data "aws_lb_listener" "stage" {
  load_balancer_arn = "${data.aws_lb.stage.arn}"
  port = 443
}

data "template_file" "re3data_task" {
  template = "${file("re3data.json")}"

  vars {
    es_host            = "${var.es_host}"
    elastic_user       = "${var.elastic_user}"
    elastic_password   = "${var.elastic_password}"
    access_key         = "${var.access_key}"
    secret_key         = "${var.secret_key}"
    bugsnag_key        = "${var.bugsnag_key}"
    memcache_servers   = "${var.memcache_servers}"
    version            = "${var.schnauzer_tags["sha"]}"
  }
}
