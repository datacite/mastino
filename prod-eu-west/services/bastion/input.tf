provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

data "aws_route53_zone" "production" {
  name         = "datacite.org"
}
data "aws_route53_zone" "internal" {
  name         = "datacite.org"
  private_zone = true
}

data "aws_subnet" "datacite-public" {
  id = var.subnet_datacite-public_id
}

data "template_file" "bastion-2024-user-data-cfg" {
  template = "${file("user_data.cfg")}"

  vars = {
    hostname     = "${var.hostname_2024}"
    fqdn         = "${var.hostname_2024}.datacite.org"
  }
}

