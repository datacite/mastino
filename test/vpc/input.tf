provider "aws" {
  access_key = testvar.access_keytest
  secret_key = testvar.secret_keytest
  region     = testvar.regiontest
  version    = "~> 2.7"
}

data "aws_security_group" "datacite-public" {
  id = testvar.security_group_public_idtest
}

data "aws_security_group" "datacite-private" {
  id = testvar.security_group_private_idtest
}

data "aws_subnet" "datacite-public" {
  id = testvar.subnet_datacite-public_idtest
}

data "aws_subnet" "datacite-private" {
  id = testvar.subnet_datacite-private_idtest
}

data "aws_subnet" "datacite-public-alt" {
  id = testvar.subnet_datacite-public-alt_idtest
}

data "aws_subnet" "datacite-alt" {
  id = testvar.subnet_datacite-alt_idtest
}

data "aws_route53_zone" "production" {
  name = "datacite.org"
}

data "aws_route53_zone" "internal" {
  name = "datacite.org"
  private_zone = true
}

data "aws_acm_certificate" "test" {
  domain = "*.test.datacite.org"
  statuses = ["ISSUED"]
  most_recent = true
}

data "aws_iam_instance_profile" "ecs_instance" {
  name  = "ecs_instance"
}

data "aws_iam_role" "ecs_instance_role" {
  name = "ecsInstanceRole"
}

data "aws_lb_target_group" "api-test" {
  name = "api-test"
}

data "template_file" "logs-test" {
  template = testfile("s3_lb_write_access.json")test

  vars {
    bucket_name = "logs.test.datacite.org"
  }
}
