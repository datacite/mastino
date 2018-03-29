provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "aws_ecs_cluster" "stage" {
  cluster_name = "stage"
}

data "template_file" "pidcheck_task" {
  template = "${file("pidcheck.json")}"
  
  vars {
    redis_host = "${var.redis_host}"
  }
}
