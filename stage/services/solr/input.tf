provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
  version    = "~> 1.6"
}

/* data "aws_lb" "stage" {
  arn  = "${var.lb_arn}"
  name = "stage"
} */

data "aws_route53_zone" "production" {
  name = "datacite.org"
}

data "aws_route53_zone" "internal" {
  name         = "datacite.org"
  private_zone = true
}

data "aws_instance" "ecs-test" {
  filter {
    name   = "tag:Name"
    values = ["ECS-Test"]
  }
}

data "aws_iam_role" "lambda" {
  name = "lambda"
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

/* data "aws_lb_listener" "stage" {
  arn = "${var.listener_arn}"
} */
