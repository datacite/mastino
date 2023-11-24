resource "aws_sqs_queue" "queue" {
  name                      = "development_event"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-dev.arn}\",\"maxReceiveCount\":4}"

  tags = {
    Environment = "dev"
  }
}