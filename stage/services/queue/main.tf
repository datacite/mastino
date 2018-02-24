resource "aws_sqs_queue" "elastic-test" {
  name                      = "elastic-test"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.terraform_queue_deadletter.arn}\",\"maxReceiveCount\":4}"

  tags {
    Environment = "test"
  }
}
