resource "aws_cloudwatch_event_rule" "solr-index-0" {
  name = "solr-index-0"
  description = "Run solr-index container via cron"
  schedule_expression = "cron(10 1,9,17 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "solr-index-1" {
  name = "solr-index-1"
  description = "Run solr-index container via cron"
  schedule_expression = "cron(10 5,13,21 * * ? *)"
}

resource "aws_cloudwatch_event_target" "solr-index-0" {
  target_id = "solr-index-0"
  rule = "${aws_cloudwatch_event_rule.solr-index-0.name}"
  arn = "${aws_lambda_function.solr-index.0.arn}"
}

resource "aws_cloudwatch_event_target" "solr-index-1" {
  target_id = "solr-index-1"
  rule = "${aws_cloudwatch_event_rule.solr-index-1.name}"
  arn = "${aws_lambda_function.solr-index.1.arn}"
}

resource "aws_lambda_function" "solr-index-0" {
  filename = "solr_index_runner.js.zip"
  function_name = "solr-index-0"
  role = "${data.aws_iam_role.lambda.arn}"
  handler = "solr_index_runner.handler"
  runtime = "nodejs4.3"
  vpc_config {
    subnet_ids = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
  }
  environment {
    variables = {
      ecs_task_def = "solr-index"
      cluster = "default"
      host = "${data.aws_instance.ecs-solr-0.private_ip}"
      clean = "true"
      solr_user = "${var.solr_user}"
      solr_password = "${var.solr_password}"
    }
  }
}

resource "aws_lambda_function" "solr-index-1" {
  filename = "solr_index_runner.js.zip"
  function_name = "solr-index-1"
  role = "${data.aws_iam_role.lambda.arn}"
  handler = "solr_index_runner.handler"
  runtime = "nodejs4.3"
  vpc_config {
    subnet_ids = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
  }
  environment {
    variables = {
      ecs_task_def = "solr-index"
      cluster = "default"
      host = "${data.aws_instance.ecs-solr-1.private_ip}"
      clean = "true"
      solr_user = "${var.solr_user}"
      solr_password = "${var.solr_password}"
    }
  }
}

resource "aws_lambda_permission" "solr-index-0" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.solr-index.0.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.solr-index-0.arn}"
}

resource "aws_lambda_permission" "solr-index-1" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.solr-index.1.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.solr-index-1.arn}"
}
