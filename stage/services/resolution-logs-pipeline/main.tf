resource "aws_ecs_service" "resolution-logs-pipeline-stage" {
  name            = "resolution-logs-pipeline-stage"
  cluster         = "${data.aws_ecs_cluster.stage.id}"
  task_definition = "${aws_ecs_task_definition.resolution-logs-pipeline-stage.arn}"
  desired_count   = 1
  // For fargate
  // launch_type = "FARGATE"

  // network_configuration {
  //   security_groups = ["${data.aws_security_group.datacite-private.id}"]
  //   subnets         = [
  //     "${data.aws_subnet.datacite-private.id}",
  //     "${data.aws_subnet.datacite-alt.id}"
  //   ]
  // }
  
  //  service_registries {
  //   registry_arn = "${aws_service_discovery_service.resolution-logs-pipeline-stage.arn}"
  // }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
  
}

resource "aws_cloudwatch_log_group" "resolution-logs-pipeline-stage" {
  name = "/ecs/resolution-logs-pipeline-stage"
}



resource "aws_ecs_task_definition" "resolution-logs-pipeline-stage" {
  family = "resolution-logs-pipeline-stage"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  // for fargate
  // network_mode = "awsvpc"
  // requires_compatibilities = ["FARGATE"]
  // cpu = "512"
  // memory = "2048"
  container_definitions =  "${data.template_file.resolution-logs-pipeline_task.rendered}"
}

resource "aws_s3_bucket" "resolution-logs-bucket-stage" {
  bucket = "resolution-logs-bucket.stage.datacite.org"
  acl = "public-read"
  // policy = "${data.template_file.resolution-logs-bucket-stage.rendered}"

  tags {
      Name = "resolution-logs-bucket-stage"
  }
  versioning {
      enabled = true
  }
}

resource "aws_s3_bucket" "merged-logs-bucket-stage" {
  bucket = "merged-logs-bucket.stage.datacite.org"
  acl = "public-read"
  // policy = "${data.template_file.merged-logs-bucket-stage.rendered}"

  tags {
      Name = "merged-logs-bucket-stage"
  }
  versioning {
      enabled = true
  }
}
//  for fargate
// resource "aws_service_discovery_service" "resolution-logs-pipeline-stage" {
//   name = "resolution-logs-pipeline.test"

//     health_check_custom_config {
//     failure_threshold = 3
//   }

//     dns_config {
//     namespace_id = "${var.namespace_id}"

//       dns_records {
//       ttl = 300
//       type = "A"
//     }
//   }
// }

