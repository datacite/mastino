resource "aws_route53_zone" "scholix" {
  name = "scholix.org"

  tags {
    Environment = "production"
  }
}

resource "aws_route53_record" "scholix-ns" {
  zone_id = "${aws_route53_zone.scholix.zone_id}"
  name = "${aws_route53_zone.scholix.name}"
  type = "NS"
  ttl = "300"
  records = [
    "${aws_route53_zone.scholix.name_servers.0}",
    "${aws_route53_zone.scholix.name_servers.1}",
    "${aws_route53_zone.scholix.name_servers.2}",
    "${aws_route53_zone.scholix.name_servers.3}"
  ]
}

resource "aws_route53_record" "mx-scholix" {
  zone_id = "${aws_route53_zone.scholix.zone_id}"
  name = "${aws_route53_zone.scholix.name}"
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

resource "aws_route53_record" "www" {
   zone_id = "${data.aws_route53_zone.scholix.zone_id}"
   name = "www.scholix.org"
   type = "CNAME"
   ttl = "300"
   records = ["ghs.googlehosted.com"]
}

resource "aws_route53_record" "sites" {
   zone_id = "${data.aws_route53_zone.scholix.zone_id}"
   name = "sites.scholix.org"
   type = "CNAME"
   ttl = "300"
   records = ["ghs.googlehosted.com"]
}
