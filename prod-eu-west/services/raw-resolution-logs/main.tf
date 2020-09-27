resource "aws_s3_bucket" "raw-resolution-logs" {
    bucket = "raw-resolution-logs.datacite.org"
    acl = "private"
    tags = {
        Name = "Raw Resolution Logs"
    }
}
