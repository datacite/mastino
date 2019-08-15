resource "aws_route53_zone" "pidapalooza" {
  name = "pidapalooza.org"

  tags {
    Environment = "production"
  }
}

resource "aws_route53_record" "pidapalooza-ns" {
  zone_id = "${aws_route53_zone.pidapalooza.zone_id}"
  name = "${aws_route53_zone.pidapalooza.name}"
  type = "NS"
  ttl = "300"
  records = "${var.name_servers}"
}

resource "aws_route53_record" "mx-pidapalooza" {
  zone_id = "${aws_route53_zone.pidapalooza.zone_id}"
  name = "${aws_route53_zone.pidapalooza.name}"
  type = "MX"
  ttl = "300"
  records = [
    "1 aspmx.l.google.com",
    "5 alt1.aspmx.l.google.com",
    "5 alt2.aspmx.l.google.com",
    "10 aspmx2.googlemail.com",
    "10 aspmx3.googlemail.com"
  ]
}
