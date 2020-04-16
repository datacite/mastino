provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "template_file" "pidservices-stage" {
  template = "${file("s3_cloudfront.json")}"

  vars {
    bucket_name = "pidservices.stage.datacite.org"
  }
}

data "aws_acm_certificate" "cloudfront-test" {
  provider = "aws.use1"
  domain = "*.test.pidservices.org"
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "pidservices" {
  name         = "pidservices.org"
}
