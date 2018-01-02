provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
  version    = "~> 1.6"
}

data "aws_route53_zone" "production" {
  name         = "datacite.org"
}

resource "aws_route53_record" "calendar" {
   zone_id = "${data.aws_route53_zone.production.zone_id}"
   name = "calendar.datacite.org"
   type = "CNAME"
   ttl = "86400"
   records = ["ghs.googlehosted.com"]
}

resource "aws_route53_record" "drive" {
   zone_id = "${data.aws_route53_zone.production.zone_id}"
   name = "drive.datacite.org"
   type = "CNAME"
   ttl = "86400"
   records = ["ghs.googlehosted.com"]
}

resource "aws_route53_record" "groups" {
   zone_id = "${data.aws_route53_zone.production.zone_id}"
   name = "groups.datacite.org"
   type = "CNAME"
   ttl = "86400"
   records = ["ghs.googlehosted.com"]
}

resource "aws_route53_record" "mail" {
   zone_id = "${data.aws_route53_zone.production.zone_id}"
   name = "mail.datacite.org"
   type = "CNAME"
   ttl = "86400"
   records = ["ghs.googlehosted.com"]
}
