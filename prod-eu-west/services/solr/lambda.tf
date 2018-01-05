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

resource "aws_cloudwatch_event_target" "solr-index" {
  count = 2
  target_id = "solr-index-${count.index}"
  rule = "${aws_cloudwatch_event_rule.solr-index-${count.index}.name}"
  arn = "${aws_lambda_function.solr-index-${count.index}.arn}"
}

resource "aws_lambda_function" "solr-index" {
  count = 2
  filename = "solr_index_runner.js.zip"
  function_name = "solr-index-${count.index}"
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
      host = "${element(data.aws_instance.ecs-solr.*.private_ip, count.index)}"
      clean = "true"
      solr_user = "${var.solr_user}"
      solr_password = "${var.solr_password}"
    }
  }
}

resource "aws_lambda_permission" "solr-index" {
  count = 2
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.solr-index-${count.index}.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.solr-index-${count.index}.arn}"
}
