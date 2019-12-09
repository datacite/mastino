resource "aws_s3_bucket" "sitemaps-search" {
    bucket = "search.datacite.org"
    acl = "public-read"
    policy = "${data.template_file.sitemaps-search.rendered}"
    website {
        index_document = "sitemap.xml.gz"
    }
    tags {
        Name = "SitemapsSearch"
    }
}

data "template_file" "sitemaps-search" {
    template = "${file("s3_public_read.json")}"

    vars {
        vpce_id = "${data.aws_vpc_endpoint.datacite.id}"
        bucket_name = "search.datacite.org"
    }
}

resource "aws_ecs_task_definition" "sitemaps-generator" {
  family = "sitemaps-generator"
  container_definitions =  "${data.template_file.sitemaps_generator_task.rendered}"
}

resource "aws_cloudwatch_event_rule" "sitemaps-generator" {
  name = "sitemaps-generator"
  description = "Run sitemaps-generator container via cron"
  schedule_expression = "cron(10 19 * * ? *)"
}

resource "aws_cloudwatch_event_target" "sitemaps-generator" {
  target_id = "sitemaps-generator"
  rule = "${aws_cloudwatch_event_rule.sitemaps-generator.name}"
  arn = "${aws_lambda_function.sitemaps-generator.arn}"

  ecs_target {
    task_count          = 1
    launch_type         = "FARGATE"
    task_definition_arn = "${aws_ecs_task_definition.sitemaps-generator.arn}"
    
    network_configuration {
      security_groups = ["${data.aws_security_group.datacite-private.id}"]
      subnets         = [
        "${data.aws_subnet.datacite-private.id}",
        "${data.aws_subnet.datacite-alt.id}"
      ]
    }
  }
}

resource "aws_lambda_function" "sitemaps-generator" {
  filename = "ecs_task_runner.js.zip"
  function_name = "sitemaps-generator"
  role = "${data.aws_iam_role.lambda.arn}"
  handler = "ecs_task_runner.handler"
  runtime = "nodejs10.x"
  vpc_config {
    subnet_ids = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
  }
  environment {
    variables = {
      ecs_task_def = "sitemaps-generator"
      cluster = "default"
      count = 1
    }
  }
}

resource "aws_lambda_permission" "sitemaps-generator" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.sitemaps-generator.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.sitemaps-generator.arn}"
}
