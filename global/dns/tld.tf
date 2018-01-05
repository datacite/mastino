resource "aws_route53_zone" "com" {
    name = "datacite.com"

    tags {
        Environment = "production"
    }
}

resource "aws_route53_record" "com-ns" {
    zone_id = "${aws_route53_zone.com.zone_id}"
    name = "datacite.com"
    type = "NS"
    ttl = "300"
    records = [
        "${aws_route53_zone.com.name_servers.0}",
        "${aws_route53_zone.com.name_servers.1}",
        "${aws_route53_zone.com.name_servers.2}",
        "${aws_route53_zone.com.name_servers.3}"
    ]
}

resource "aws_route53_zone" "eu" {
    name = "datacite.eu"

    tags {
        Environment = "production"
    }
}

resource "aws_route53_record" "eu-ns" {
    zone_id = "${aws_route53_zone.eu.zone_id}"
    name = "datacite.eu"
    type = "NS"
    ttl = "300"
    records = [
        "${aws_route53_zone.eu.name_servers.0}",
        "${aws_route53_zone.eu.name_servers.1}",
        "${aws_route53_zone.eu.name_servers.2}",
        "${aws_route53_zone.eu.name_servers.3}"
    ]
}
