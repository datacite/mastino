# BagIt Service
resource "aws_ecs_service" "bagit-stage" {
  name = "bagit-stage"
  cluster = "${data.aws_ecs_cluster.stage.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.bagit-stage.arn}"
  desired_count = 1

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.bagit-stage.arn}"
  }
}

resource "aws_cloudwatch_log_group" "bagit-stage" {
  name = "/ecs/bagit-stage"
}

resource "aws_ecs_task_definition" "bagit-stage" {
  family = "bagit-stage"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "2048"

  container_definitions =  "${data.template_file.bagit_task.rendered}"
}

resource "aws_service_discovery_service" "bagit-stage" {
  name = "bagit"

  health_check_custom_config {
    failure_threshold = 1
  }

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.internal-stage.id}"
    dns_records {
      ttl = 300
      type = "A"
    }
  }
}
