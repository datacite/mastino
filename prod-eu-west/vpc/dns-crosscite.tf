resource "aws_route53_zone" "crosscite" {
    name = "crosscite.org"

    tags = {
        Environment = "production"
    }
}

resource "aws_route53_record" "crosscite-ns" {
    zone_id = "${aws_route53_zone.crosscite.zone_id}"
    name = "${aws_route53_zone.crosscite.name}"
    type = "NS"
    ttl = "300"
    records = [
        "${aws_route53_zone.crosscite.name_servers.0}",
        "${aws_route53_zone.crosscite.name_servers.1}",
        "${aws_route53_zone.crosscite.name_servers.2}",
        "${aws_route53_zone.crosscite.name_servers.3}"
    ]
}

data "aws_acm_certificate" "crosscite" {
  domain = "*.crosscite.org"
  statuses = ["ISSUED"]
}
