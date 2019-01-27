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

data "template_file" "doi" {
  template = "${file("s3_cloudfront.json")}"

  vars {
    bucket_name = "doi.datacite.org"
  }
}

data "aws_acm_certificate" "cloudfront" {
  provider = "aws.use1"
  domain = "datacite.org"
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

data "aws_s3_bucket" "logs" {
  bucket = "logs.datacite.org"
}
