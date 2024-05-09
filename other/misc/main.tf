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


// Using A record rather than CNAME per https://www.siteground.com/kb/point-website-domain-siteground
resource "aws_route53_record" "mdc" {
   zone_id = data.aws_route53_zone.makedatacount.zone_id
   name = "makedatacount.org"
   type = "A"
   ttl = var.ttl
   records = [var.siteground_ip_mdc_prod]
}

// Using A record rather than CNAME per https://www.siteground.com/kb/point-website-domain-siteground
resource "aws_route53_record" "mdc-wildcard" {
   zone_id = data.aws_route53_zone.makedatacount.zone_id
   name = "*.makedatacount.org"
   type = "A"
   ttl = var.ttl
   records = [var.siteground_ip_mdc_prod]
}

resource "aws_route53_record" "mdc-summit" {
   zone_id = data.aws_route53_zone.makedatacount.zone_id
   name = "summit.makedatacount.org"
   type = "A"
   ttl = var.ttl
   records = [var.siteground_ip_mdc_summit_prod]
}

resource "aws_route53_record" "mdc-summit-wildcard" {
   zone_id = data.aws_route53_zone.makedatacount.zone_id
   name = "*.summit.makedatacount.org"
   type = "A"
   ttl = var.ttl
   records = [var.siteground_ip_mdc_summit_prod]
}
