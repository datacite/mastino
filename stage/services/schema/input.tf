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

data "template_file" "schema-stage" {
  template = "${file("s3_cloudfront.json")}"

  vars {
    bucket_name = "schema.stage.datacite.org"
  }
}

data "aws_acm_certificate" "cloudfront-stage" {
  provider = "aws.use1"
  domain = "*.stage.datacite.org"
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "cloudfront-test" {
  provider = "aws.use1"
  domain = "*.test.datacite.org"
  statuses = ["ISSUED"]
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
