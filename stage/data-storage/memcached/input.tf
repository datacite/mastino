provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
  version    = "~> 1.6"
}

data "aws_security_group" "datacite-private" {
  id = "${var.security_group_id}"
}

data "aws_route53_zone" "internal" {
  name         = "datacite.org"
  private_zone = true
}

data "aws_elasticache_cluster" "memcached-stage" {
  cluster_id = "memcached-stage"
}
