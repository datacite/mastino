provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "aws_route53_zone" "production" {
  name         = "datacite.org"
}

data "aws_lb" "test" {
  name = "${var.lb_name}"
}

data "aws_instance" "compose-test" {
  instance_id = "${var.compose_id}"
}
