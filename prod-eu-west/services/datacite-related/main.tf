resource "aws_ecs_task_definition" "datacite-related" {
  family = "datacite-related"
  execution_role_arn = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  container_definitions =  "${data.template_file.datacite_related_task.rendered}"
}

resource "aws_cloudwatch_log_group" "datacite-related" {
  name = "/ecs/datacite-related"
}

resource "aws_cloudwatch_event_rule" "datacite-related" {
  name = "datacite-related"
  description = "Run datacite-related container via cron"
  schedule_expression = "cron(20 4 * * ? *)"
}

resource "aws_cloudwatch_event_target" "datacite-related" {
  target_id = "datacite-related"
  rule = "${aws_cloudwatch_event_rule.datacite-related.name}"
  arn = "${aws_lambda_function.datacite-related.arn}"
}

resource "aws_lambda_function" "datacite-related" {
  filename = "ecs_task_runner.js.zip"
  function_name = "datacite-related"
  role = "${data.aws_iam_role.lambda.arn}"
  handler = "ecs_task_runner.handler"
  runtime = "nodejs6.10"
  vpc_config {
    subnet_ids = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
  }
  environment {
    variables = {
      ecs_task_def = "datacite-related"
      cluster = "test"
      count = 1
    }
  }
}

resource "aws_lambda_permission" "datacite-related" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.datacite-related.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.datacite-related.arn}"
}
