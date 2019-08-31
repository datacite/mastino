resource "aws_sqs_queue" "doi" {
  name                      = "production_doi"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter.arn}\",\"maxReceiveCount\":4}"

  tags {
    Environment = "production"
  }
}

resource "aws_sqs_queue" "event" {
  name                      = "production_event"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter.arn}\",\"maxReceiveCount\":4}"

  tags {
    Environment = "production"
  }
}

resource "aws_sqs_queue" "volpino" {
  name                      = "production_volpino"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter.arn}\",\"maxReceiveCount\":4}"
  visibility_timeout_seconds = 120

  tags {
    Environment = "production"
  }
}

resource "aws_sqs_queue" "lupo" {
  name                      = "production_lupo"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter.arn}\",\"maxReceiveCount\":4}"
  visibility_timeout_seconds = 120

  tags {
    Environment = "production"
  }
}

resource "aws_sqs_queue" "lupo-background" {
  name                      = "production_lupo_background"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter.arn}\",\"maxReceiveCount\":4}"
  visibility_timeout_seconds = 3600

  tags {
    Environment = "production"
  }
}

resource "aws_sqs_queue" "lupo-transfer" {
  name                      = "production_lupo_transfer"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter.arn}\",\"maxReceiveCount\":4}"
  visibility_timeout_seconds = 3600

  tags {
    Environment = "production"
  }
}

resource "aws_sqs_queue" "levriero" {
  name                      = "production_levriero"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter.arn}\",\"maxReceiveCount\":4}"

  tags {
    Environment = "production"
  }
}

resource "aws_sqs_queue" "sashimi" {
  name                      = "production_sashimi"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter.arn}\",\"maxReceiveCount\":4}"

  tags {
    Environment = "production"
  }
}

resource "aws_sqs_queue" "usage" {
  name                      = "production_usage"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter.arn}\",\"maxReceiveCount\":4}"

  tags {
    Environment = "production"
  }
}

resource "aws_sqs_queue" "dead-letter" {
  name                      = "production_dead-letter"

  tags {
    Environment = "production"
  }
}

resource "aws_iam_policy" "sqs" {
  name = "sqs"
  policy = "${data.template_file.queue.rendered}"
}
