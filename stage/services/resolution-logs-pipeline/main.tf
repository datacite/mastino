
resource "aws_s3_bucket" "resolution-logs-bucket-stage" {
  bucket = "resolution-logs-bucket.stage.datacite.org"
  acl = "public-read"
  // policy = "${data.template_file.resolution-logs-bucket-stage.rendered}"

  tags {
      Name = "resolution-logs-bucket-stage"
  }
  versioning {
      enabled = true
  }
}

resource "aws_s3_bucket" "merged-logs-bucket-stage" {
  bucket = "merged-logs-bucket.stage.datacite.org"
  acl = "public-read"
  // policy = "${data.template_file.merged-logs-bucket-stage.rendered}"

  tags {
      Name = "merged-logs-bucket-stage"
  }
  versioning {
      enabled = true
  }
}