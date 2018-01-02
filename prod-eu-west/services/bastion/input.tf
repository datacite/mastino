provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
  version    = "~> 1.6"
}

data "aws_route53_zone" "production" {
  name         = "datacite.org"
}
data "aws_route53_zone" "internal" {
  name         = "datacite.org"
  private_zone = true
}

data "aws_subnet" "datacite-public" {
  id = "${var.subnet_datacite-public_id}"
}

data "template_file" "bastion-user-data-cfg" {
  template = "${file("user_data.cfg")}"

  vars {
    hostname     = "${var.hostname}"
    fqdn         = "${var.hostname}.datacite.org"
  }
}
