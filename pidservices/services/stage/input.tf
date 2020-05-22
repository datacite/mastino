provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

provider "aws" {
  # us-east-1 instance
  access_key = var.access_key
  secret_key = var.secret_key
  region = "us-east-1"
  alias = "use1"
}

data "aws_acm_certificate" "cloudfront-pidservices" {
  provider = aws.use1
  domain = "pidservices.org"
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "pidservices" {
  name         = "pidservices.org"
}
