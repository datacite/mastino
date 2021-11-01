resource "aws_efs_file_system" "alt-stage" {
  creation_token = "efs-alt-stage"

  tags = {
    Name = "EFS-Alt-Stage"
  }
}

resource "aws_efs_access_point" "geoip-alt-stage" {
  file_system_id = aws_efs_file_system.alt-stage.id

  posix_user {
    uid = 1001
    gid = 1001
    secondary_gids = [1003, 1004]
  }

  root_directory {
    path = "/geoip"

    creation_info {
      owner_uid      = 1001
      owner_gid      = 1001
      permissions    = 755
    }
  }
}

resource "aws_efs_mount_target" "alt-stage" {
  file_system_id  = aws_efs_file_system.alt-stage.id
  subnet_id       = data.aws_subnet.datacite-private.id
  security_groups = [data.aws_security_group.datacite-private.id]
}

resource "aws_route53_record" "efs-alt-stage" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "efs-alt.stage.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [aws_efs_file_system.alt-stage.dns_name]
}
