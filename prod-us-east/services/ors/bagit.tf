# BagIt Service
resource "aws_ecs_service" "bagit" {
  name = "bagit"
  cluster = "${data.aws_ecs_cluster.default-us.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.bagit.arn}"
  desired_count = 1

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }


   service_registries {
      registry_arn = "${aws_service_discovery_service.bagit.arn}"
   }

}

resource "aws_cloudwatch_log_group" "bagit" {
  name = "/ecs/bagit"
}

# BagIt Task Definition
resource "aws_ecs_task_definition" "bagit" {
  family = "bagit"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "2048"

  container_definitions =  "${data.template_file.bagit_task.rendered}"
}

# Service Discovery for Bagit
resource "aws_service_discovery_service" "bagit" {
   name = "bagit"

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
