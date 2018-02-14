resource "aws_s3_bucket" "openingscience" {
    bucket = "book.openingscience.org"
    acl = "public-read"
    policy = "${data.template_file.openingscience.rendered}"
    website {
        index_document = "index.html"
        error_document = "404.html"
    }
    tags {
        Name = "Opening Science"
    }
}
