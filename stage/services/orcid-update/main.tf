resource "aws_ecs_task_definition" "orcid-update-test" {
  family = "orcid-update-test"
  container_definitions =  "${data.template_file.orcid_update_test_task.rendered}"
}

resource "aws_cloudwatch_event_rule" "orcid-update-test" {
  name = "orcid-update-test"
  description = "Run orcid-update container via cron"
  schedule_expression = "cron(40 5 * * ? *)"
}

resource "aws_cloudwatch_event_target" "orcid-update-test" {
  target_id = "orcid-update-test"
  rule = "${aws_cloudwatch_event_rule.orcid-update-test.name}"
  arn = "${aws_lambda_function.orcid-update-test.arn}"
}

resource "aws_lambda_function" "orcid-update-test" {
  filename = "ecs_task_runner.js.zip"
  function_name = "orcid-update-test"
  role = "${data.aws_iam_role.lambda.arn}"
  handler = "ecs_task_runner.handler"
  runtime = "nodejs4.3"
  vpc_config {
    subnet_ids = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
  }
  environment {
    variables = {
      ecs_task_def = "orcid-update-test"
      cluster = "test"
      count = 1
    }
  }
}

resource "aws_lambda_permission" "orcid-update-test" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.orcid-update-test.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.orcid-update-test.arn}"
}
