resource "aws_s3_bucket" "papertrail" {
    bucket = "papertrail.datacite.org"
    acl = "private"
    tags {
        Name = "Papertrail"
    }
}
