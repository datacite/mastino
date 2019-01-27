provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

provider "aws" {
  # us-east-1 instance
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "us-east-1"
  alias = "use1"
}

data "template_file" "pidapalooza" {
  template = "${file("s3_cloudfront.json")}"

  vars {
    bucket_name = "pidapalooza.org"
  }
}

data "aws_acm_certificate" "pidapalooza" {
  provider = "aws.use1"
  domain = "pidapalooza.org"
  statuses = ["ISSUED"]
  most_recent = true
}

data "aws_route53_zone" "pidapalooza" {
  name = "pidapalooza.org"
}

data "aws_s3_bucket" "logs" {
  bucket = "logs.datacite.org"
}
