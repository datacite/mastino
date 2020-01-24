resource "aws_sqs_queue" "doi-test" {
  name                      = "stage_doi"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"

  tags {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "event-test" {
  name                      = "stage_event"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"

  tags {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "volpino-test" {
  name                      = "stage_volpino"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"
  visibility_timeout_seconds = 120
  
  tags {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "lupo-test" {
  name                      = "stage_lupo"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"
  visibility_timeout_seconds = 120
  
  tags {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "lupo-background-test" {
  name                      = "stage_lupo_background"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"
  visibility_timeout_seconds = 3600

  tags {
    Environment = "test"
  }
}

resource "aws_sqs_queue" "lupo-transfer-test" {
  name                      = "stage_lupo_transfer"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-test.arn}\",\"maxReceiveCount\":4}"
  visibility_timeout_seconds = 3600

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

resource "aws_sqs_queue" "levriero-usage-test" {
  name                      = "stage_levriero_usage"
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

resource "aws_sqs_queue" "sashimi-test" {
  name                      = "stage_sashimi"
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
