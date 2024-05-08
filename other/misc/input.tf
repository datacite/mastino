provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

data "aws_route53_zone" "pidnotebooks" {
  name         = "pidnotebooks.org"
}

data "aws_route53_zone" "makedatacount" {
  name         = "makedatacount.org"
}