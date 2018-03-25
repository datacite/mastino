provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "aws_route53_zone" "production" {
  name         = "datacite.org"
}

data "aws_route53_zone" "internal" {
  name         = "datacite.org"
  private_zone = true
}

data "aws_lb" "stage" {
  name = "${var.lb_name}"
}

data "aws_instance" "compose-stage" {
  instance_id = "${var.compose_id}"
}
