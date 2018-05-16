provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
  version    = "~> 1.6"
}

data "aws_security_group" "datacite-public" {
  id = "${var.security_group_public_id}"
}

data "aws_security_group" "datacite-private" {
  id = "${var.security_group_private_id}"
}

data "aws_subnet" "datacite-public" {
  id = "${var.subnet_datacite-public_id}"
}

data "aws_subnet" "datacite-private" {
  id = "${var.subnet_datacite-private_id}"
}

data "aws_subnet" "datacite-public-alt" {
  id = "${var.subnet_datacite-public-alt_id}"
}

data "aws_subnet" "datacite-alt" {
  id = "${var.subnet_datacite-alt_id}"
}

data "aws_route53_zone" "production" {
  name = "datacite.org"
}

data "aws_route53_zone" "internal" {
  name = "datacite.org"
  private_zone = true
}

data "aws_acm_certificate" "default" {
  domain = "*.datacite.org"
  statuses = ["ISSUED"]
}

data "aws_iam_instance_profile" "ecs_instance" {
  name  = "ecs_instance"
}

data "aws_iam_role" "ecs_instance_role" {
  name = "ecsInstanceRole"
}

data "aws_lb_target_group" "data-us" {
  name = "data-us"
}

data "template_file" "logs-us" {
  template = "${file("s3_lb_write_access.json")}"

  vars {
    bucket_name = "logs-us.datacite.org"
  }
}
