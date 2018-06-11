resource "aws_ecs_task_definition" "orcid-update" {
  family = "orcid-update"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  container_definitions =  "${data.template_file.orcid_update_task.rendered}"
}

resource "aws_cloudwatch_log_group" "orcid-update" {
  name = "/ecs/orcid-update"
}

resource "aws_cloudwatch_event_rule" "orcid-update" {
  name = "orcid-update"
  description = "Run orcid-update container via cron"
  schedule_expression = "cron(40 6 * * ? *)"
}

resource "aws_cloudwatch_event_target" "orcid-update" {
  target_id = "orcid-update"
  rule = "${aws_cloudwatch_event_rule.orcid-update.name}"
  arn = "${aws_lambda_function.orcid-update.arn}"
}

resource "aws_lambda_function" "orcid-update" {
  filename = "ecs_task_runner.js.zip"
  function_name = "orcid-update"
  role = "${data.aws_iam_role.lambda.arn}"
  handler = "ecs_task_runner.handler"
  runtime = "nodejs6.10"
  vpc_config {
    subnet_ids = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
  }
  environment {
    variables = {
      ecs_task_def = "orcid-update"
      cluster = "default"
      count = 1
    }
  }
}

resource "aws_lambda_permission" "orcid-update" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.orcid-update.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.orcid-update.arn}"
}
