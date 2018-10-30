provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "aws_ecs_cluster" "default" {
  cluster_name = "default"
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

data "template_file" "pidcheck_task" {
  template = "${file("pidcheck.json")}"

  vars {
    redis_host = "${var.redis_host}",
    version = "${var.pidcheck_tags["version"]}"
  }
}

data "aws_security_group" "datacite-private" {
  id = "${var.security_group_id}"
}

data "aws_subnet" "datacite-private" {
  id = "${var.subnet_datacite-private_id}"
}

data "aws_subnet" "datacite-alt" {
  id = "${var.subnet_datacite-alt_id}"
}