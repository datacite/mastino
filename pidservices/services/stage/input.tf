provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

data "aws_acm_certificate" "cloudfront-test" {
  provider = aws
  domain = "pidservices.org"
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "pidservices" {
  name         = "pidservices.org"
}
