provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
  version    = "~> 2.70"
}

provider "aws" {
  # us-east-1 instance
  access_key = var.access_key
  secret_key = var.secret_key
  region = "us-east-1"
  alias = "use1"
}

data "aws_acm_certificate" "cloudfront-pidnotebooks" {
  provider = aws.use1
  domain = "pidnotebooks.org"
  statuses = ["ISSUED"]
}
