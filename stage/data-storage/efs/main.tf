resource "aws_efs_file_system" "stage" {
  creation_token = "efs-stage"

  tags = {
    Name = "EFS-Stage"
  }
}
