# Neo service
resource "aws_ecs_service" "neo" {
  name = "neo"
  cluster = "${data.aws_ecs_cluster.default-us.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.neo.arn}"
  desired_count = 1

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

   service_registries {
      registry_arn = "${aws_service_discovery_service.neo.arn}"
   }

}


resource "aws_cloudwatch_log_group" "neo" {
  name = "/ecs/neo"
}


# Neo Task Definition
resource "aws_ecs_task_definition" "neo" {
   family = "neo"
   execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
   requires_compatibilities = ["FARGATE"]
   network_mode = "awsvpc"
   cpu = "512"
   memory = "2048"

   container_definitions = "${data.template_file.neo_task.rendered}"
}


# Neo Service Discovery
resource "aws_service_discovery_service" "neo" {
   name = "neo"

   health_check_custom_config {
      failure_threshold = 1
   }

   dns_config {
      namespace_id = "${aws_service_discovery_private_dns_namespace.ors_namespace.id}"
      dns_records {
         ttl = 6000
         type = "A"
      }
   }

}


resource "aws_service_discovery_private_dns_namespace" "ors_namespace" {
   name = "ors.local"
   description = "Private DNS namespace for connecting containers between services"
   vpc = "${data.aws_subnet.datacite-private.vpc_id}"
}

