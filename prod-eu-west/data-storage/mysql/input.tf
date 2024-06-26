provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

data "aws_db_instance" "db" {
  db_instance_identifier = "db2-restore-snapshot"
}

data "aws_subnet" "datacite-public" {
  id = var.subnet_datacite-public_id
}

data "aws_subnet" "datacite-public-alt" {
  id = var.subnet_datacite-public-alt_id
}

data "aws_subnet" "datacite-private" {
  id = var.subnet_datacite-private_id
}

data "aws_subnet" "datacite-alt" {
  id = var.subnet_datacite-alt_id
}

data "aws_route53_zone" "internal" {
  name         = "datacite.org"
  private_zone = true
}
