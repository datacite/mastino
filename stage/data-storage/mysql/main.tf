resource "aws_db_instance" "db-stage" {
  identifier                  = "db-stage"
  snapshot_identifier         = "db-stage-initial-snapshot"
  storage_type                = "gp2"
  allocated_storage           = 300
  engine                      = "mysql"
  engine_version              = "8.0.36"
  instance_class              = "db.m5.large"
  username                    = var.mysql_user
  password                    = var.mysql_password
  maintenance_window          = "thu:00:00-thu:00:30"
  backup_window               = "01:00-01:30"
  backup_retention_period     = 8
  availability_zone           = "eu-west-1a"
  db_subnet_group_name        = "datacite"
  vpc_security_group_ids      = [data.aws_security_group.datacite-private.id]
  parameter_group_name        = aws_db_parameter_group.datacite-stage-mysql8.id
  auto_minor_version_upgrade  = "true"
  allow_major_version_upgrade = "true"
  final_snapshot_identifier   = "db-stage-final-snapshot"
  max_allocated_storage       = 1000
  deletion_protection         = "true"

  tags = {
    Name = "stage"
  }

  lifecycle {
    prevent_destroy = "true"
    ignore_changes = [
      engine_version
    ]
  }

  apply_immediately = "true"
}

resource "aws_db_parameter_group" "datacite-stage-mysql8" {
  name        = "datacite-stage-mysql8"
  family      = "mysql8.0"
  description = "RDS datacite-stage mysql8 parameter group"

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


resource "aws_db_parameter_group" "datacite-stage-mysql84" {
  name        = "datacite-stage-mysql84"
  family      = "mysql8.4"
  description = "RDS datacite-stage mysql84 parameter group"

  // The following are old character set defaults pre MySQL 8
  // At time of configuration data still uses the old setup
  // We could change default here but it's a good idea that we migrate the character sets
  // and then change this default
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
}

resource "aws_route53_record" "internal-db-stage" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "db.stage.datacite.org"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_db_instance.db-stage.address]
}

resource "aws_route53_record" "rds-stage" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "test.rds.datacite.org"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_db_instance.db-stage.address]
}
