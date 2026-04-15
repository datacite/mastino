
provider "aws" {

  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

data "aws_route53_zone" "pidapalooza" {
  name         = "pidapalooza.org"
}

data "aws_acm_certificate" "cloudfront-pidapalooza" {
  region = "us-east-1"
  domain = "pidapalooza.org"
  statuses = ["ISSUED"]
}


