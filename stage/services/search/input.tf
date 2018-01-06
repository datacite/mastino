provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
  version    = "~> 1.6"
}

data "template_file" "search-stage" {
    template = "${file("policies/s3_public_read.json")}"

    vars {
        vpce_id = "${aws_vpc_endpoint.datacite.id}"
        bucket_name = "${aws_route53_record.search-stage.name}"
    }
}

data "aws_ecs_cluster" "stage" {
  cluster_name = "stage"
}
