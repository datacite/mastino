provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
  version    = "~> 1.6"
}

resource "aws_db_instance" "db-stage" {
  identifier = "db-stage"
  snapshot_identifier = "db-stage-final-snapshot"
  storage_type = "gp2"
  allocated_storage = 300
  engine = "mysql"
  engine_version = "5.7.19"
  instance_class = "db.m4.large"
  username = "${var.mysql_user}"
  password = "${var.mysql_password}"
  maintenance_window = "thu:00:00-thu:00:30"
  backup_window = "01:00-01:30"
  backup_retention_period = 8
  availability_zone = "eu-west-1a"
  db_subnet_group_name = "datacite"
  vpc_security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
  parameter_group_name = "${aws_db_parameter_group.datacite-stage.id}"
  auto_minor_version_upgrade = "true"
  allow_major_version_upgrade = "true"
  final_snapshot_identifier = "db-stage-final-snapshot"
  tags {
    Name = "stage"
  }
  lifecycle {
      prevent_destroy = "true"
  }
  apply_immediately = "true"
}

resource "aws_db_parameter_group" "datacite-stage" {
    name = "datacite-stage"
    family = "mysql5.7"
    description = "RDS datacite-stage parameter group"

    parameter {
      name = "character_set_server"
      value = "utf8"
    }

    parameter {
      name = "collation_server"
      value = "utf8_unicode_ci"
    }

    parameter {
      name = "character_set_client"
      value = "utf8"
    }

    parameter {
      name = "max_allowed_packet"
      value = 50000000
    }

    parameter {
      name = "read_only"
      value = "0"
    }

    parameter {
      name = "slow_query_log"
      value = "1"
    }

    parameter {
      name = "log_queries_not_using_indexes"
      value = "1"
    }

    parameter {
      name = "log_throttle_queries_not_using_indexes"
      value = "0"
    }
}

data "aws_security_group" "datacite-private" {
  id = "${var.security_group_id}"
}

data "aws_route53_zone" "internal" {
  name         = "datacite.org"
  private_zone = true
}

resource "aws_route53_record" "internal-db-stage" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name = "db.stage.datacite.org"
  type = "CNAME"
  ttl = "30"
  records = ["${aws_db_instance.db-stage.address}"]
}
