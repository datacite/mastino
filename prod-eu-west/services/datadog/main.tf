resource "aws_lambda_function" "logs" {
  filename = "logs.py.zip"
  function_name = "logs"
  role = "${data.aws_iam_role.lambda.arn}"
  handler = "logs.lambda_handler"
  runtime = "python2.7"
  source_code_hash = "${base64sha256(file("logs.py.zip"))}"
  timeout = "120"
  memory_size = "1024"

  vpc_config {
    subnet_ids = ["${data.aws_subnet.datacite-private.id}", "${data.aws_subnet.datacite-alt.id}"]
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
  }
  environment {
    variables = {
      dd_api_key = "${var.dd_api_key}"
    }
  }
}
