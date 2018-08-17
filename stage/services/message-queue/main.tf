resource "aws_sqs_queue" "elastic-test" {
  name                      = "stage_elastic"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"

  tags {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "doi-test" {
  name                      = "stage_doi"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"

  tags {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "lupo-test" {
  name                      = "stage_lupo"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"

  tags {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "levriero-test" {
  name                      = "stage_levriero"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"

  tags {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "usage-test" {
  name                      = "stage_usage"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"

  tags {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "dead-letter-test" {
  name                      = "stage_dead-letter"

  tags {
    Environment = "test"
  }
}

resource "aws_iam_policy" "sqs-test" {
  name = "sqs-test"
  policy = "${data.template_file.queue-test.rendered}"
}
