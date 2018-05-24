// resource "aws_cloudwatch_event_rule" "set-minted" {
//   name = "set-minted"
//   description = "Run set-minted API call via cron"
//   schedule_expression = "cron(55 0,4,8,12,16,20 * * ? *)"
// }

// resource "aws_cloudwatch_event_target" "set-minted" {
//   target_id = "set-minted"
//   rule = "${aws_cloudwatch_event_rule.set-minted.name}"
//   arn = "${aws_lambda_function.set-minted.arn}"
// }

resource "aws_lambda_function" "set-minted" {
  filename = "set_minted_runner.js.zip"
  function_name = "set-minted"
  role = "${data.aws_iam_role.lambda.arn}"
  handler = "set_minted_runner.handler"
  runtime = "nodejs6.10"
  source_code_hash = "${base64sha256(file("set_minted_runner.js.zip"))}"
  timeout = "270"

  vpc_config {
    subnet_ids = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
  }
  environment {
    variables = {
      host     = "${var.host}"
      username = "${var.username}"
      password = "${var.password}"
    }
  }
}

// resource "aws_lambda_permission" "set-minted" {
//   statement_id = "AllowExecutionFromCloudWatch"
//   action = "lambda:InvokeFunction"
//   function_name = "${aws_lambda_function.set-minted.function_name}"
//   principal = "events.amazonaws.com"
//   source_arn = "${aws_cloudwatch_event_rule.set-minted.arn}"
// }
