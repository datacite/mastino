resource "aws_sqs_queue" "elastic" {
  name                      = "production_elastic"
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

resource "aws_sqs_queue" "lupo" {
  name                      = "production_lupo"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter.arn}\",\"maxReceiveCount\":4}"

  tags {
    Environment = "production"
  }
}

resource "aws_sqs_queue" "lagottino" {
  name                      = "production_lagottino"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter.arn}\",\"maxReceiveCount\":4}"

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
