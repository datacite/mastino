module "fargate-scheduled-task" {
  source  = "baikonur-oss/fargate-scheduled-task/aws"
  version = "v2.0.1"

  execution_role_arn  = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  name                = "sitemaps-generator-test"
  schedule_expression = "cron(05 9 * * ? *)"
  is_enabled          = "true"

  target_cluster_arn = "stage"

  task_definition_arn = "${aws_ecs_task_definition.sitemaps-generator-test.arn}"
  task_role_arn       = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  task_count          = "1"

  subnet_ids = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
  security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
}

resource "aws_s3_bucket" "sitemaps-search-test" {
    bucket = "search.test.datacite.org"
    acl = "public-read"
    policy = templatefile("s3_public_read.json",
      {
        vpce_id = data.aws_vpc_endpoint.datacite.id,
        bucket_name = "search.test.datacite.org"
      })
    website {
        index_document = "index.html"
    }
    tags {
        Name = "SitemapsSearchTest"
    }
}

// data "template_file" "sitemaps-search-test" {
//     template = "${file("s3_public_read.json")}"

//     vars {
//         vpce_id = "${data.aws_vpc_endpoint.datacite.id}"
//         bucket_name = "search.test.datacite.org"
//     }
// }

resource "aws_ecs_task_definition" "sitemaps-generator-test" {
  family = "sitemaps-generator-test"
  container_definitions =  templatefile("sitemaps-generator.json",
    {
      access_key  = var.access_key,
      secret_key  = var.secret_key,
      region      = var.region
    })
}

// resource "aws_cloudwatch_event_rule" "sitemaps-generator-test" {
//   name = "sitemaps-generator-test"
//   description = "Run sitemaps-generator-test container via cron"
//   schedule_expression = "cron(05 9 * * ? *)"
// }

// resource "aws_cloudwatch_event_target" "sitemaps-generator-test" {
//   target_id = "sitemaps-generator-test"
//   rule = "${aws_cloudwatch_event_rule.sitemaps-generator-test.name}"
//   arn = "${aws_lambda_function.sitemaps-generator-test.arn}"
// }

// resource "aws_lambda_function" "sitemaps-generator-test" {
//   filename = "ecs_task_runner.js.zip"
//   function_name = "sitemaps-generator-test"
//   role = "${data.aws_iam_role.lambda.arn}"
//   handler = "ecs_task_runner.handler"
//   runtime = "nodejs10.x"
//   vpc_config {
//     subnet_ids = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
//     security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
//   }
//   environment {
//     variables = {
//       ecs_task_def = "sitemaps-generator-test"
//       cluster = "stage"
//       count = 1
//     }
//   }
// }

// resource "aws_lambda_permission" "sitemaps-generator-test" {
//   statement_id = "AllowExecutionFromCloudWatch"
//   action = "lambda:InvokeFunction"
//   function_name = "${aws_lambda_function.sitemaps-generator-test.function_name}"
//   principal = "events.amazonaws.com"
//   source_arn = "${aws_cloudwatch_event_rule.sitemaps-generator-test.arn}"
// }
