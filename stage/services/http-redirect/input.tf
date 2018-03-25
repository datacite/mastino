provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "aws_ecs_cluster" "test" {
  cluster_name = "test"
}

data "aws_iam_role" "ecs_service" {
  name = "ecs_service"
}

data "template_file" "http-redirect_task" {
  template = "${file("http-redirect.json")}"

  vars {
    version            = "${var.http-redirect_tags["sha"]}"
  }
}
