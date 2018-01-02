resource "aws_route53_record" "spf-mailgun" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "mg.datacite.org"
    type = "TXT"
    ttl = "300"
    records = [
        "v=spf1 include:mailgun.org ~all"
    ]
}

resource "aws_route53_record" "dkim-mailgun" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "k1._domainkey.mg.datacite.org"
    type = "TXT"
    ttl = "300"
    records = [
        "k=rsa; p=${var.dkim}"
    ]
}

resource "aws_route53_record" "mailgun" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "email.mg.datacite.org"
    type = "CNAME"
    ttl = "86400"
    records = ["mailgun.org"]
}

resource "aws_route53_record" "mx-mailgun" {
    zone_id = "${data.aws_route53_zone.production.zone_id}"
    name = "mg.datacite.org"
    type = "MX"
    ttl = "300"
    records = [
        "10 mxa.mailgun.org",
        "10 mxb.mailgun.org"
    ]
}
