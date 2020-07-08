resource "aws_efs_file_system" "default" {
  creation_token = "efs"

  tags = {
    Name = "EFS"
  }
}

resource "aws_efs_access_point" "strapi" {
  file_system_id = aws_efs_file_system.default.id
  
  posix_user {
    uid = 1001
    gid = 1001
    secondary_gids = [1003, 1004]
  }

  root_directory {
    path = "/strapi"

    creation_info {
      owner_uid      = 1001
      owner_gid      = 1001
      permissions    = 755
    }
  }
}

resource "aws_efs_mount_target" "default" {
  file_system_id  = aws_efs_file_system.default.id
  subnet_id       = data.aws_subnet.datacite-private.id
  security_groups = [data.aws_security_group.datacite-private.id]
}

resource "aws_route53_record" "efs" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "efs.datacite.org"
   type = "CNAME"
   ttl = var.ttl
   records = [aws_efs_file_system.default.dns_name]
}
