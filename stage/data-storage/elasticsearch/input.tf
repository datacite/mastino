provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
  version    = "~> 2.7.0"
}

data "aws_security_group" "datacite-private" {
  id = "${var.security_group_id}"
}

data "aws_subnet" "datacite-private" {
  id = "${var.subnet_datacite-private_id}"
}

data "aws_route53_zone" "production" {
  name         = "datacite.org"
}

data "aws_route53_zone" "internal" {
  name         = "datacite.org"
  private_zone = true
}

data "template_file" "functionbeat" {
    template = "${file("s3_full_access.json")}"

    vars {
        bucket_name = "functionbeat-deploy-stage"
        principal = "${var.principal}"
    }
}
data "aws_iam_role" "CognitoAccessForAmazonES" {
  name = "CognitoAccessForAmazonES"
}

data "aws_cognito_user_pools" "user_pool" {
  name = "kibana-userpool"
}

// data "aws_acm_certificate" "stage" {
//   domain = "*.stage.datacite.org"
//   statuses = ["ISSUED"]
//   most_recent = true
// }
