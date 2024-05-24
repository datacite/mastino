resource "aws_db_instance" "db-test" {
  identifier                  = "db-test"
  storage_type                = "gp2"
  allocated_storage           = 300
  engine                      = "mysql"
  engine_version              = "8.036"
  instance_class              = "db.m5.large"
  username                    = var.mysql_user
  password                    = var.mysql_password
  maintenance_window          = "thu:00:00-thu:00:30"
  backup_window               = "01:00-01:30"
  backup_retention_period     = 8
  availability_zone           = "eu-west-1b"
  db_subnet_group_name        = "datacite"
  vpc_security_group_ids      = [data.aws_security_group.datacite-private.id]
  parameter_group_name        = aws_db_parameter_group.datacite-test.id
  auto_minor_version_upgrade  = "true"
  allow_major_version_upgrade = "true"
  final_snapshot_identifier   = "db-test-final-snapshot"
  max_allocated_storage       = 1000
  deletion_protection         = "true"

  tags = {
    Name = "test"
  }

  lifecycle {
    prevent_destroy = "true"
    ignore_changes = [
      engine_version
     ]
  }

  apply_immediately = "true"
}

resource "aws_db_parameter_group" "datacite-test" {
  name        = "datacite-test"
  family      = "mysql5.7"
  description = "RDS datacite-test parameter group"

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


resource "aws_db_parameter_group" "datacite-test-mysql8" {
  name        = "datacite-test-mysql8"
  family      = "mysql8.0"
  description = "RDS datacite-test mysql8 parameter group"

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
    name  = "log_output"
    value = "FILE"
  }
}


resource "aws_route53_record" "internal-db-test" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "db.test.datacite.org"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_db_instance.db-test.address]
}

resource "aws_route53_record" "internal-db-test-ec2" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "db.test.ec2.datacite.org"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_db_instance.db-test.address]
}