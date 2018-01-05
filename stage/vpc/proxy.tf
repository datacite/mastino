resource "aws_route53_record" "internal-proxy" {
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "proxy.datacite.org"
    type = "A"
    ttl = "300"
    records = ["10.0.0.116"]
}

resource "aws_route53_record" "ec2-proxy-public" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "proxy.ec2.datacite.org"
    type = "A"
    ttl = "3600"
    records = ["52.208.28.107"]
}

resource "aws_route53_record" "ec2-proxy" {
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "proxy.ec2.datacite.org"
    type = "A"
    ttl = "300"
    records = ["10.0.0.116"]
}
