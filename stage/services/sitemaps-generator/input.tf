provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

// data "template_file" "sitemaps_generator_test_task" {
//   template = "${file("sitemaps-generator.json")}"

//   vars {
//     access_key  = "${var.access_key}"
//     secret_key  = "${var.secret_key}"
//     region      = "${var.region}"
//   }
// }

data "aws_vpc_endpoint" "datacite" {
  vpc_id       = "${var.vpc_id}"
  service_name = "com.amazonaws.eu-west-1.s3"
}

data "aws_ecs_cluster" "stage" {
  cluster_name = "stage"
}

data "aws_iam_role" "lambda" {
  name = "lambda"
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
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
