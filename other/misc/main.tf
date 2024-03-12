resource "aws_route53_record" "pidnotebooks-apex" {
     zone_id = data.aws_route53_zone.pidnotebooks.zone_id
     name = "pidnotebooks.org"
     type = "A"
     ttl = "300"
     records = var.github_pages_records
}

resource "aws_route53_record" "pidnotebooks-www" {
    zone_id = data.aws_route53_zone.pidnotebooks.zone_id
    name = "www.pidnotebooks.org"
    type = "CNAME"
    ttl = "3600"
    records = ["pidnotebooks.org"]
}
