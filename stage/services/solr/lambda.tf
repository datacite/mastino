resource "aws_cloudwatch_event_rule" "solr-index-stage" {
  name = "solr-index-stage"
  description = "Run solr-index container via cron"
  schedule_expression = "cron(0,5,10,15,20,25,30,35,40,45,50,55 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "solr-index-stage" {
  target_id = "solr-index-stage"
  rule = "${aws_cloudwatch_event_rule.solr-index-stage.name}"
  arn = "${aws_lambda_function.solr-index-stage.arn}"
}

resource "aws_lambda_function" "solr-index-stage" {
  filename = "solr_index_runner.js.zip"
  function_name = "solr-index-stage"
  role = "${data.aws_iam_role.lambda.arn}"
  handler = "solr_index_runner.handler"
  runtime = "nodejs6.10"
  vpc_config {
    subnet_ids = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
  }
  environment {
    variables = {
      ecs_task_def = "solr-index-stage"
      cluster = "stage"
      host = "${data.aws_instance.ecs-stage.private_ip}"
      clean = "true"
      solr_user = "${var.solr_user}"
      solr_password = "${var.solr_password}"
    }
  }
}

resource "aws_lambda_permission" "solr-index-stage" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.solr-index-stage.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.solr-index-stage.arn}"
}
