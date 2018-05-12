provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "aws_iam_role" "lambda" {
  name = "lambda"
}

data "aws_instance" "ecs-solr" {
  filter {
    name   = "tag:Group"
    values = ["ECS-Solr"]
  }
}

data "aws_instance" "ecs-solr-1" {
  filter {
    name   = "tag:Name"
    values = ["ECS1"]
  }
}

data "aws_instance" "ecs-solr-2" {
  filter {
    name   = "tag:Name"
    values = ["ECS2"]
  }
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

data "aws_lb" "default" {
  name = "${var.lb_name}"
}

data "aws_lb_listener" "default" {
  load_balancer_arn = "${data.aws_lb.default.arn}"
  port = 443
}
