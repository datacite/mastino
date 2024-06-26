provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

data "aws_security_group" "datacite-private" {
  id = var.security_group_id
}

data "aws_route53_zone" "internal" {
  name         = "datacite.org"
  private_zone = true
}
