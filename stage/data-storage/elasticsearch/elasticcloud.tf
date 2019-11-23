resource "aws_route53_record" "kibana-test" {
  zone_id = "${data.aws_route53_zone.production.zone_id}"
  name = "kibana.test.datacite.org"
  type = "CNAME"
  ttl = "${var.ttl}"
  records = ["${var.kibana-name}"]
}

resource "aws_route53_record" "kibana-test-internal" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name = "kibana.test.datacite.org"
  type = "CNAME"
  ttl = "${var.ttl}"
  records = ["${var.kibana-name}"]
}
