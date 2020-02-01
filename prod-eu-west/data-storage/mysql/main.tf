resource "aws_db_parameter_group" "datacite57" {
  name        = "datacite57"
  family      = "mysql5.7"
  description = "RDS datacite parameter group"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "collation_server"
    value = "utf8_unicode_ci"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }

  parameter {
    name  = "max_allowed_packet"
    value = 50000000
  }

  parameter {
    name  = "read_only"
    value = "0"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "log_queries_not_using_indexes"
    value = "1"
  }

  parameter {
    name  = "log_throttle_queries_not_using_indexes"
    value = "0"
  }

  parameter {
    name  = "log_output"
    value = "FILE"
  }

  parameter {
    name  = "log_bin_trust_function_creators"
    value = "1"
  }
}

resource "aws_db_subnet_group" "datacite-prod" {
  name        = "datacite-prod"
  description = "RDS production subnet group"

  subnet_ids = [
    "${data.aws_subnet.datacite-public.id}",
    "${data.aws_subnet.datacite-public-alt.id}",
    "${data.aws_subnet.datacite-private.id}",
    "${data.aws_subnet.datacite-alt.id}",
  ]
}

resource "aws_route53_record" "internal-db2" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name    = "db.datacite.org"
  type    = "CNAME"
  ttl     = "${var.ttl}"
  records = ["${data.aws_db_instance.db.address}"]
}

resource "aws_route53_record" "internal-db2-ec2" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name    = "db.ec2.datacite.org"
  type    = "CNAME"
  ttl     = "${var.ttl}"
  records = ["${data.aws_db_instance.db.address}"]
}

resource "aws_route53_record" "internal-db7" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name    = "dbread.ec2.datacite.org"
  type    = "CNAME"
  ttl     = "${var.ttl}"
  records = ["${data.aws_db_instance.db.address}"]
}

resource "aws_route53_record" "split-db1" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name    = "db1.datacite.org"
  type    = "CNAME"
  ttl     = "${var.ttl}"
  records = ["${data.aws_db_instance.db.address}"]
}

resource "aws_route53_record" "internal-db1-ec2" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name    = "db1.ec2.datacite.org"
  type    = "CNAME"
  ttl     = "${var.ttl}"
  records = ["${data.aws_db_instance.db.address}"]
}

resource "aws_route53_record" "rds-production" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name    = "production.rds.datacite.org"
  type    = "CNAME"
  ttl     = "${var.ttl}"
  records = ["${data.aws_db_instance.db.address}"]
}
