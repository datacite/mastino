resource "aws_route53_zone" "production" {
    name = "datacite.org"

    tags {
        Environment = "production"
    }
}

resource "aws_route53_record" "production-ns" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "datacite.org"
    type = "NS"
    ttl = "300"
    records = [
        "${aws_route53_zone.production.name_servers.0}",
        "${aws_route53_zone.production.name_servers.1}",
        "${aws_route53_zone.production.name_servers.2}",
        "${aws_route53_zone.production.name_servers.3}"
    ]
}

resource "aws_route53_zone" "internal" {
    name = "datacite.org"
    vpc_id  = "${var.vpc_id}"

    tags {
        Environment = "internal"
    }
}

resource "aws_route53_zone_association" "us-east-1" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  vpc_id  = "${data.aws_vpc.us-east-1.id}"
  vpc_region = "us-east-1"
}

resource "aws_route53_record" "internal-ns" {
    zone_id = "${aws_route53_zone.internal.zone_id}"
    name = "datacite.org"
    type = "NS"
    ttl = "30"
    records = [
        "${aws_route53_zone.internal.name_servers.0}",
        "${aws_route53_zone.internal.name_servers.1}",
        "${aws_route53_zone.internal.name_servers.2}",
        "${aws_route53_zone.internal.name_servers.3}"
    ]
}

resource "aws_route53_record" "status" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "status.datacite.org"
    type = "CNAME"
    ttl = "3600"
    records = ["${var.status_dns_name}"]
}

resource "aws_route53_record" "changelog" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "changelog.datacite.org"
    type = "CNAME"
    ttl = "3600"
    records = ["${var.changelog_dns_name}"]
}

resource "aws_route53_record" "support" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "support.datacite.org"
    type = "CNAME"
    ttl = "300"
    records = ["${var.support_dns_name}"]
}

resource "aws_route53_record" "mx-datacite" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "${data.aws_route53_zone.production.name}"
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

resource "aws_route53_record" "txt-datacite" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "${data.aws_route53_zone.production.name}"
    type = "TXT"
    ttl = "300"
    records = [
        "${var.google_site_verification_record}",
        "v=spf1 include:_spf.google.com ~all",
        "${var.ms_record}",
        "${var.verification_record}"
    ]
}

resource "aws_route53_record" "dkim-datacite" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "google._domainkey.${data.saws_route53_zone.production.name}"
    type = "TXT"
    ttl = "300"
    records = ["${var.dkim_record}"]
}

resource "aws_route53_record" "dmarc-datacite" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "_dmarc.${data.aws_route53_zone.production.name}"
    type = "TXT"
    ttl = "300"
    records = ["${var.dmarc_record}"]
}
