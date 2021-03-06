resource "aws_lambda_function" "logs" {
  filename = "lambda_function.py.zip"
  function_name = "logs"
  role = "${data.aws_iam_role.lambda.arn}"
  handler = "lambda_function.lambda_handler"
  runtime = "python2.7"
  source_code_hash = "${base64sha256(file("lambda_function.py.zip"))}"
  timeout = "120"
  memory_size = "1024"

  vpc_config {
    subnet_ids = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
  }
  environment {
    variables = {
      DD_API_KEY = "${var.dd_api_key}"
    }
  }
}
