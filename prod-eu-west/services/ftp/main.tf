resource "aws_route53_record" "ftp" {
   zone_id = "${data.aws_route53_zone.production.zone_id}"
   name = "ftp.datacite.org"
   type = "CNAME"
   ttl = "${var.ttl}"
   records = ["dev.ec2.datacite.org"]
}

resource "aws_route53_record" "dev_ec2" {
   zone_id = "${data.aws_route53_zone.production.zone_id}"
   name = "dev.ec2.datacite.org"
   type = "A"
   ttl = "${var.ttl}"
   records = ["52.16.21.185"]
}

resource "aws_route53_record" "ec2-dev" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "dev.ec2.datacite.org"
   type = "A"
   ttl = "${var.ttl}"
   records = ["10.0.0.39"]
}
