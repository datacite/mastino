# Neo service
resource "aws_ecs_service" "neo-stage" {
  name = "neo-stage"
  cluster = "${data.aws_ecs_cluster.stage.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.neo-stage.arn}"
  desired_count = 1

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.neo-stage.arn}"
  }
}

resource "aws_cloudwatch_log_group" "neo-stage" {
  name = "/ecs/neo-stage"
}

resource "aws_ecs_task_definition" "neo-stage" {
   family = "neo-stage"
   execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
   requires_compatibilities = ["FARGATE"]
   network_mode = "awsvpc"
   cpu = "512"
   memory = "2048"

   container_definitions = "${data.template_file.neo_task.rendered}"
}

resource "aws_service_discovery_service" "neo-stage" {
  name = "neo.test"

  health_check_custom_config {
    failure_threshold = 1
  }

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.internal.id}"
    dns_records {
      ttl = 300
      type = "A"
    }
  }
}

# Service Discovery Namepace
resource "aws_service_discovery_private_dns_namespace" "internal" {
  name = "datacite.org"
  vpc = "${data.aws_subnet.datacite-private.vpc_id}"
}