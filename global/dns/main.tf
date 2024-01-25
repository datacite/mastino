resource "aws_route53_zone" "production" {
    name = "datacite.org"

    tags = {
        Environment = "production"
    }
}

resource "aws_route53_record" "production-ns" {
    zone_id = aws_route53_zone.production.zone_id
    name = "datacite.org"
    type = "NS"
    ttl = "300"
    records = [
        aws_route53_zone.production.name_servers.0,
        aws_route53_zone.production.name_servers.1,
        aws_route53_zone.production.name_servers.2,
        aws_route53_zone.production.name_servers.3,
    ]
}

resource "aws_route53_zone" "internal" {
    name = "datacite.org"

    vpc {
        vpc_id = var.vpc_id
    }

    tags = {
        Environment = "internal"
    }
}

resource "aws_route53_record" "internal-ns" {
    zone_id = aws_route53_zone.internal.zone_id
    name = "datacite.org"
    type = "NS"
    ttl = "30"
    records = [
        aws_route53_zone.internal.name_servers.0,
        aws_route53_zone.internal.name_servers.1,
        aws_route53_zone.internal.name_servers.2,
        aws_route53_zone.internal.name_servers.3,
    ]
}

resource "aws_route53_record" "status" {
    zone_id = aws_route53_zone.production.zone_id
    name = "status.datacite.org"
    type = "CNAME"
    ttl = "3600"
    records = [var.status_dns_name]
}

resource "aws_route53_record" "dkim-cm" {
    zone_id = aws_route53_zone.production.zone_id
    name = "cm._domainkey.datacite.org"
    type = "TXT"
    ttl = "300"
    records = [
        "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCzCLTKFpC7ffe+qYFRfLFnFeZCMLh6dHIAcA5iYswUbgWcICqRyb1cZHCZicO7noWi9ZyMngXY4drp4EjNTF9EumrzP63HnAE3D5kFSQICQOVsZsRao+LZVWuNi1F0nxxA9xfbomAbGgfI6jsPGReOOxcvcaSX+hT7H0JcM0uBRQIDAQAB"
    ]
}

resource "aws_route53_record" "changelog" {
    zone_id = aws_route53_zone.production.zone_id
    name = "changelog.datacite.org"
    type = "CNAME"
    ttl = "3600"
    records = [var.changelog_dns_name]
}

resource "aws_route53_record" "support" {
    zone_id = aws_route53_zone.production.zone_id
    name = "support.datacite.org"
    type = "CNAME"
    ttl = "300"
    records = [var.support_dns_name]
}

resource "aws_route53_record" "design" {
    zone_id = aws_route53_zone.production.zone_id
    name = "design.datacite.org"
    type = "CNAME"
    ttl = "300"
    records = [var.design_dns_name]
}

resource "aws_route53_record" "mx-datacite" {
    zone_id = aws_route53_zone.production.zone_id
    name = aws_route53_zone.production.name
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
    zone_id = aws_route53_zone.production.zone_id
    name = aws_route53_zone.production.name
    type = "TXT"
    ttl = "300"
    records = [
        var.google_site_verification_record,
        "v=spf1 include:_spf.google.com include:_spf.salesforce.com ~all",
        var.ms_record,
        var.verification_record
    ]
}

resource "aws_route53_record" "dkim-datacite" {
    zone_id = aws_route53_zone.production.zone_id
    name = "google._domainkey.datacite.org"
    type = "TXT"
    ttl = "300"
    records = [var.dkim_record]
}

resource "aws_route53_record" "dkim-salesforce" {
    zone_id = aws_route53_zone.production.zone_id
    name = "datacite._domainkey.datacite.org"
    type = "TXT"
    ttl = "300"
    records = [var.dkim_salesforce]
}

resource "aws_route53_record" "dkim-alt-salesforce" {
    zone_id = aws_route53_zone.production.zone_id
    name = "datacite.org._domainkey.datacite.org"
    type = "TXT"
    ttl = "300"
    records = [var.dkim_alt_salesforce]
}

resource "aws_route53_record" "dmarc-datacite" {
    zone_id = aws_route53_zone.production.zone_id
    name = "_dmarc.datacite.org"
    type = "TXT"
    ttl = "300"
    records = [var.dmarc_record]
}

resource "aws_route53_record" "github_datacite" {
    zone_id = aws_route53_zone.production.zone_id
    name = "_github-challenge-datacite.datacite.org"
    type = "TXT"
    ttl = "300"
    records = ["7aea104794"]
}

resource "aws_route53_record" "lists" {
    zone_id = aws_route53_zone.production.zone_id
    name = "lists.datacite.org"
    type = "CNAME"
    ttl = "300"
    records = ["cname.createsend.com"]
}

resource "aws_route53_record" "corpus-prototype-prod" {
    zone_id = aws_route53_zone.production.zone_id
    name = "corpus.datacite.org"
    type = "A"
    ttl = "300"
    records = ["54.229.227.84"]
}

// Google DataCite dns entries

resource "aws_route53_record" "calendar" {
   zone_id = aws_route53_zone.production.zone_id
   name = "calendar.datacite.org"
   type = "CNAME"
   ttl = "86400"
   records = ["ghs.googlehosted.com"]
}

resource "aws_route53_record" "drive" {
   zone_id = aws_route53_zone.production.zone_id
   name = "drive.datacite.org"
   type = "CNAME"
   ttl = "86400"
   records = ["ghs.googlehosted.com"]
}

resource "aws_route53_record" "groups" {
   zone_id = aws_route53_zone.production.zone_id
   name = "groups.datacite.org"
   type = "CNAME"
   ttl = "86400"
   records = ["ghs.googlehosted.com"]
}

resource "aws_route53_record" "mail" {
   zone_id = aws_route53_zone.production.zone_id
   name = "mail.datacite.org"
   type = "CNAME"
   ttl = "86400"
   records = ["ghs.googlehosted.com"]
}

// Mailgun dns entries

resource "aws_route53_record" "spf-mailgun" {
    zone_id = aws_route53_zone.production.zone_id
    name = "mg.datacite.org"
    type = "TXT"
    ttl = "300"
    records = [
        "v=spf1 include:mailgun.org ~all"
    ]
}

resource "aws_route53_record" "dkim-mailgun" {
    zone_id = aws_route53_zone.production.zone_id
    name = "k1._domainkey.mg.datacite.org"
    type = "TXT"
    ttl = "300"
// Note this is the public key here
    records = [
        "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDAWN4K4d+IYySrapJz7+El5L92s3NKOTJbOCkU/uy7SPOQJuQX1lZDFsVINUYlvAvkz+43MRaVt8VceU5nxIvAXQErjwevrPxXnYj0l+Nk8k502cAZLtktKd5TTSRyGVNH3AS51qVKts8P+uKRGDXefX1OA956oS1PELMl73tWRQIDAQAB"
    ]
}

resource "aws_route53_record" "mailgun" {
    zone_id = aws_route53_zone.production.zone_id
    name = "email.mg.datacite.org"
    type = "CNAME"
    ttl = "86400"
    records = ["mailgun.org"]
}

resource "aws_route53_record" "mx-mailgun" {
    zone_id = aws_route53_zone.production.zone_id
    name = "mg.datacite.org"
    type = "MX"
    ttl = "300"
    records = [
        "10 mxa.mailgun.org",
        "10 mxb.mailgun.org"
    ]
}

// Vercel dns entries

// Commons staging
resource "aws_route53_record" "akita-stage" {
    zone_id = aws_route53_zone.production.zone_id
    name = "commons.stage.datacite.org"
    type = "CNAME"
    ttl = 300
    records = ["commons.datacite.vercel.app"]
}

// Fabrica staging
resource "aws_route53_record" "doi-stage" {
    zone_id = aws_route53_zone.production.zone_id
    name = "doi.stage.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = ["doi.datacite.vercel.app"]
}

// Fabrica test
resource "aws_route53_record" "doi-test" {
    zone_id = aws_route53_zone.production.zone_id
    name = "doi.test.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = ["bracco-test.vercel.app"]
}

// Siteground (blog/homepage)

// Using A record rather than CNAME per https://www.siteground.com/kb/point-website-domain-siteground
resource "aws_route53_record" "blog-stage" {
   zone_id = aws_route53_zone.production.zone_id
   name = "blog.stage.datacite.org"
   type = "A"
   ttl = var.ttl
   records = [var.siteground_ip_stage]
}

// Using A record rather than CNAME per https://www.siteground.com/kb/point-website-domain-siteground
resource "aws_route53_record" "blog-stage-wildcard" {
   zone_id = aws_route53_zone.production.zone_id
   name = "*.blog.stage.datacite.org"
   type = "A"
   ttl = var.ttl
   records = [var.siteground_ip_stage]
}
