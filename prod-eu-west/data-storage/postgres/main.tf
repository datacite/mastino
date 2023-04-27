# resource "aws_db_instance" "postgres" {
#   identifier                  = "postgres"
#   storage_type                = "gp2"
#   allocated_storage           = 20
#   engine                      = "postgres"
#   engine_version              = "12.7"
#   instance_class              = "db.t3.micro"
#   username                    = var.postgres_user
#   password                    = var.postgres_password
#   maintenance_window          = "thu:00:00-thu:00:30"
#   backup_window               = "01:00-01:30"
#   backup_retention_period     = 8
#   availability_zone           = "eu-west-1a"
#   db_subnet_group_name        = "datacite"
#   vpc_security_group_ids      = [data.aws_security_group.datacite-private.id]
#   parameter_group_name        = aws_db_parameter_group.datacite.id
#   auto_minor_version_upgrade  = "false"
#   allow_major_version_upgrade = "false"
#   final_snapshot_identifier   = "postgres-final-snapshot"

#   lifecycle {
#     prevent_destroy = "true"
#   }

#   apply_immediately = "true"
# }

# resource "aws_db_parameter_group" "datacite" {
#   name        = "postgress-datacite"
#   family      = "postgres12"
#   description = "RDS datacite postgres parameter group"
# }

# resource "aws_route53_record" "internal-postgres" {
#   zone_id = data.aws_route53_zone.internal.zone_id
#   name    = "postgres.datacite.org"
#   type    = "CNAME"
#   ttl     = "300"
#   records = [aws_db_instance.postgres.address]
# }
