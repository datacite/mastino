resource "aws_sqs_queue" "doi-test" {
  name                      = "test_doi"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"

  tags = {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "event-test" {
  name                      = "test_event"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"

  tags = {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "volpino-test" {
  name                      = "test_volpino"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"
  visibility_timeout_seconds = 120

  tags = {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "lupo-test" {
  name                      = "test_lupo"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"
  visibility_timeout_seconds = 120

  tags = {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "lupo-background-test" {
  name                      = "test_lupo_background"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"
  visibility_timeout_seconds = 3600

  tags = {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "lupo-import-test" {
  name                      = "test_lupo_import"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"
  visibility_timeout_seconds = 3600

  tags = {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "lupo-import-other-doi-test" {
  name                      = "test_lupo_import_other_doi"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"
  visibility_timeout_seconds = 3600

  tags = {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "lupo-transfer-test" {
  name                      = "test_lupo_transfer"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"
  visibility_timeout_seconds = 3600

  tags = {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "levriero-test" {
  name                      = "test_levriero"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"

  tags = {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "levriero-usage-test" {
  name                      = "test_levriero_usage"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"

  tags = {
    Environment = "test"
  }
}


resource "aws_sqs_queue" "usage-test" {
  name                      = "test_usage"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"

  tags = {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "sashimi-test" {
  name                      = "test_sashimi"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"

  tags = {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "analytics" {
  name                      = "test_analytics"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"
  tags {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "dead-letter-test" {
  name                      = "test_dead-letter"

  tags = {
    Environment = "test"
  }
}

resource "aws_iam_policy" "sqs-test" {
  name = "sqs-test"
  policy = "${data.template_file.queue-test.rendered}"
}
