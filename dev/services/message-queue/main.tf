resource "aws_sqs_queue" "event-dev" {
  name                      = "development_event"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-dev.arn}\",\"maxReceiveCount\":4}"

  tags {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "doi-dev" {
  name                      = "development_doi"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-dev.arn}\",\"maxReceiveCount\":4}"

  tags {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "lupo-dev" {
  name                      = "development_lupo"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-dev.arn}\",\"maxReceiveCount\":4}"

  tags {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "lagottino-dev" {
  name                      = "development_lagottino"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-dev.arn}\",\"maxReceiveCount\":4}"

  tags {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "doi-testing" {
  name                      = "test_doi"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-dev.arn}\",\"maxReceiveCount\":4}"

  tags {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "lupo-testing" {
  name                      = "test_lupo"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-dev.arn}\",\"maxReceiveCount\":4}"

  tags {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "levriero-dev" {
  name                      = "development_levriero"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-dev.arn}\",\"maxReceiveCount\":4}"

  tags {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "dead-letter-dev" {
  name                      = "development_dead-letter"

  tags {
    Environment = "dev"
  }
}

resource "aws_iam_policy" "sqs-dev" {
  name = "sqs-dev"
  policy = "${data.template_file.queue-dev.rendered}"
}
