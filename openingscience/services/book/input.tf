provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "template_file" "openingscience" {
  template = "${file("s3_public_read.json")}"

  vars {
    bucket_name = "book.pidapalooza.org"
  }
}
