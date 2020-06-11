resource "aws_efs_file_system" "stage" {
  creation_token = "efs-stage"

  tags = {
    Name = "EFS-Stage"
  }
}

resource "aws_efs_mount_target" "stage" {
  file_system_id = aws_efs_file_system.stage.id
  subnet_id      = data.aws_subnet.datacite-private.id
}
