resource "aws_route53_record" "elasticcloud-test" {
  zone_id = "${data.aws_route53_zone.production.zone_id}"
  name = "elasticcloud.test.datacite.org"
  type = "CNAME"
  ttl = "${var.ttl}"
  records = ["${var.elasticcloud-name}"]
}

resource "aws_route53_record" "elasticcloud-test-internal" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name = "elasticcloud.test.datacite.org"
  type = "CNAME"
  ttl = "${var.ttl}"
  records = ["${var.elasticcloud-name}"]
}
