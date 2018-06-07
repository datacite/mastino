# Security Credentials
provider "aws" {
   region = "us-east-1"
}

# Task Roles Required for Services
data "aws_iam_role" "exec" {
   name = "ecsTaskExecutionRole"
}


# Launch a ECS cluster
resource "aws_ecs_cluster" "Test" {
    name = "ORS_Test"
}

# Neo Task Definition
resource "aws_ecs_task_definition" "ors_neo" {
   family = "ors_neo"
   container_definitions = "${data.template_file.neo.rendered}"
   requires_compatibilities = ["FARGATE"]
   network_mode = "awsvpc"
   cpu = "512"
   memory = "2048"

   execution_role_arn = "${data.aws_iam_role.exec.arn}",
   task_role_arn = "arn:aws:iam::280922329489:role/ECS_task_role"
}

# Neo Service
resource "aws_ecs_service" "neo_service" {
   name = "neo_service"
   cluster = "${aws_ecs_cluster.Test.id}"
   task_definition = "${aws_ecs_task_definition.ors_neo.arn}"


   desired_count = 1
   launch_type = "FARGATE"

   service_registries {
      registry_arn = "${aws_service_discovery_service.neo.arn}"
   }

   network_configuration {
      security_groups   = ["${aws_security_group.allow_all.id}"]
      subnets           = [ "${aws_subnet.pubSubnet.id}"]
      assign_public_ip = true
   }
}

# BagIt Task Definition
resource "aws_ecs_task_definition" "ors_bagit" {
   family = "ors_bagit"
   container_definitions = "${data.template_file.bagit.rendered}",
   requires_compatibilities = ["FARGATE"],
   network_mode = "awsvpc"
   cpu = "512",
   memory = "2048",
   execution_role_arn = "${data.aws_iam_role.exec.arn}",
}

# BagIt Service
resource "aws_ecs_service" "bagit_service" {
   name = "bagit_service"
   cluster = "${aws_ecs_cluster.Test.id}"
   task_definition = "${aws_ecs_task_definition.ors_bagit.arn}"
   desired_count = 1
   launch_type = "FARGATE"
   network_configuration {
      security_groups   = ["${aws_security_group.allow_all.id}"]
      subnets           = [ "${aws_subnet.pubSubnet.id}"]
      assign_public_ip = true
   }
}

# WSGI Task Definition
resource "aws_ecs_task_definition" "ors_wsgi" {
   family = "ors_wsgi"
   container_definitions = "${data.template_file.wsgi.rendered}",
   requires_compatibilities = ["FARGATE"],
   network_mode = "awsvpc"
   cpu = "512",
   memory = "2048",
   execution_role_arn = "${data.aws_iam_role.exec.arn}",
}

# WSGI Service
resource "aws_ecs_service" "wsgi_service" {
   name = "wsgi_service"
   cluster = "${aws_ecs_cluster.Test.id}"
   task_definition = "${aws_ecs_task_definition.ors_wsgi.arn}"
   desired_count = 1
   launch_type = "FARGATE"

   network_configuration {
      security_groups   = ["${aws_security_group.allow_all.id}"]
      subnets           = [ "${aws_subnet.pubSubnet.id}"]
      assign_public_ip = true
   }
}
