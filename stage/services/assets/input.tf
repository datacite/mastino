provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

data "template_file" "assets-stage" {
  template = file("s3_cloudfront.json")

  vars = {
    bucket_name = "assets.stage.datacite.org"
  }
}

data "aws_acm_certificate" "cloudfront-stage" {
  provider = aws.use1
  domain = "*.stage.datacite.org"
  statuses = ["ISSUED"]
  most_recent = true
}

data "aws_route53_zone" "production" {
  name         = "datacite.org"
}

data "aws_route53_zone" "internal" {
  name         = "datacite.org"
  private_zone = true
}

data "aws_s3_bucket" "logs-stage" {
  bucket = "logs.stage.datacite.org"
}
