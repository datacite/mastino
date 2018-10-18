resource "aws_cloudwatch_event_rule" "store-crawler-results" {
  name                = "store-crawler-results"
  description         = "Run store-crawler-results API call via cron"
  schedule_expression = "cron(42 1 * * ? *)"
}

resource "aws_cloudwatch_event_target" "store-crawler-results" {
  target_id = "store-crawler-results"
  rule      = "${aws_cloudwatch_event_rule.store-crawler-results.name}"
  arn       = "${aws_lambda_function.store-crawler-results.arn}"
}

resource "aws_lambda_function" "store-crawler-results" {
  filename         = "store_crawler_results.py.zip"
  function_name    = "store-crawler-results"
  role             = "${data.aws_iam_role.lambda.arn}"
  handler          = "store_crawler_results_runner.lambda_handler"
  runtime          = "python3.6"
  source_code_hash = "${base64sha256(file("store_crawler_results.py.zip"))}"
  timeout          = "270"

  vpc_config {
    subnet_ids         = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
  }

  environment {
    variables = {
      REDIS_HOST     = "${var.redis_host}"
      API_ENDPOINT   = "${var.api_endpoint}"
      ADMIN_USERNAME = "${var.admin_username}"
      ADMIN_PASSWORD = "${var.admin_password}"
    }
  }
}

resource "aws_lambda_permission" "store-crawler-results" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.store-crawler-results.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.store-crawler-results.arn}"
}
