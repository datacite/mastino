# Redis service
resource "aws_ecs_service" "redis-stage" {
  name = "redis-stage"
  cluster = "${data.aws_ecs_cluster.stage.id}"
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.redis-stage.arn}"
  desired_count = 1

  network_configuration {
    security_groups = ["${data.aws_security_group.datacite-private.id}"]
    subnets         = [
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
  }

   servie_registries {
      registry_arn = "${aws_service_discovery_service.redis.arn}"
   }

}

resource "aws_cloudwatch_log_group" "redis-stage" {
  name = "/ecs/redis-stage"
}

# Neo Task Definition
resource "aws_ecs_task_definition" "redis-stage" {
   family = "redis-stage"
   execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
   requires_compatibilities = ["FARGATE"]
   network_mode = "awsvpc"
   cpu = "512"
   memory = "2048"

   container_definitions = "${data.template_file.redis_task.rendered}"
}


# Redis Service Discovery
resource "aws_service_discovery_service" "redis" {
   name = "redis"

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

