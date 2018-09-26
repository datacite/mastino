resource "aws_ecs_service" "indexd-stage" {
   name = "indexd-stage"
   cluster = "${data.aws_ecs_cluster.stage.id}"
   launch_type = "FARGATE"
   task_definition = "${aws_ecs_task_definition.indexd-stage.arn}"
   desired_count = 1

   network_configuration {
      security_groups = ["${data.aws_security_group.datacite-private.id}"]
      subnets         = [
         "${data.aws_subnet.datacite-private.id}",
         "${data.aws_subnet.datacite-alt.id}"
      ]
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.indexd-stage.arn}"
  }
}

resource "aws_cloudwatch_log_group" "indexd-stage" {
  name = "/ecs/indexd-stage"
}

resource "aws_ecs_task_definition" "indexd-stage" {
   family = "indexd-stage"
   execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
   requires_compatibilities = ["FARGATE"]
   network_mode = "awsvpc"
   cpu = "512"
   memory = "2048"

   container_definitions = "${data.template_file.indexd_task.rendered}"
}


// Service Discovery
resource "aws_service_discovery_service" "indexd-stage" {
  name = "indexd"

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

resource "aws_route53_record" "indexd-stage" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "indexd.test.datacite.org"
   type = "A"

   alias {
     name = "${aws_service_discovery_service.indexd-stage.name}.${aws_service_discovery_private_dns_namespace.internal-stage.name}"
     zone_id = "${aws_service_discovery_private_dns_namespace.internal-stage.hosted_zone}"
     evaluate_target_health = true
   }
}
