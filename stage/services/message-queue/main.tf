resource "aws_sqs_queue" "doi-stage" {
  name                      = "stage_doi"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-stage.arn}\",\"maxReceiveCount\":4}"

  tags = {
    Environment = "stage"
  }
}

resource "aws_sqs_queue" "event-stage" {
  name                      = "stage_event"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-stage.arn}\",\"maxReceiveCount\":4}"

  tags = {
    Environment = "stage"
  }
}

resource "aws_sqs_queue" "volpino-stage" {
  name                      = "stage_volpino"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-stage.arn}\",\"maxReceiveCount\":4}"
  visibility_timeout_seconds = 120

  tags = {
    Environment = "stage"
  }
}

resource "aws_sqs_queue" "lupo-stage" {
  name                      = "stage_lupo"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-stage.arn}\",\"maxReceiveCount\":4}"
  visibility_timeout_seconds = 120

  tags = {
    Environment = "stage"
  }
}

resource "aws_sqs_queue" "lupo-background-stage" {
  name                      = "stage_lupo_background"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-stage.arn}\",\"maxReceiveCount\":4}"
  visibility_timeout_seconds = 3600

  tags = {
    Environment = "stage"
  }
}

resource "aws_sqs_queue" "lupo-import-stage" {
  name                      = "stage_lupo_import"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-stage.arn}\",\"maxReceiveCount\":4}"
  visibility_timeout_seconds = 3600

  tags = {
    Environment = "stage"
  }
}

resource "aws_sqs_queue" "lupo-import-other-doi-stage" {
  name                      = "stage_lupo_import_other_doi"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-stage.arn}\",\"maxReceiveCount\":4}"
  visibility_timeout_seconds = 3600

  tags = {
    Environment = "stage"
  }
}

resource "aws_sqs_queue" "lupo-transfer-stage" {
  name                      = "stage_lupo_transfer"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-stage.arn}\",\"maxReceiveCount\":4}"
  visibility_timeout_seconds = 3600

  tags = {
    Environment = "stage"
  }
}

resource "aws_sqs_queue" "levriero-stage" {
  name                      = "stage_levriero"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-stage.arn}\",\"maxReceiveCount\":4}"

  tags = {
    Environment = "stage"
  }
}

resource "aws_sqs_queue" "levriero-usage-stage" {
  name                      = "stage_levriero_usage"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-stage.arn}\",\"maxReceiveCount\":4}"

  tags = {
    Environment = "stage"
  }
}


resource "aws_sqs_queue" "usage-stage" {
  name                      = "stage_usage"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-stage.arn}\",\"maxReceiveCount\":4}"

  tags = {
    Environment = "stage"
  }
}

resource "aws_sqs_queue" "sashimi-stage" {
  name                      = "stage_sashimi"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-stage.arn}\",\"maxReceiveCount\":4}"

  tags = {
    Environment = "stage"
  }
}

resource "aws_sqs_queue" "salesforce-stage" {
  name                      = "stage_salesforce"
  visibility_timeout_seconds = 60
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-stage.arn}\",\"maxReceiveCount\":4}"

  tags = {
    Environment = "stage"
  }
}

resource "aws_sqs_queue" "analytics" {
  name                      = "stage_analytics"
  visibility_timeout_seconds = 60
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead-letter-stage.arn}\",\"maxReceiveCount\":4}"

  tags = {
    Environment = "stage"
  }
}

resource "aws_sqs_queue" "dead-letter-stage" {
  name                      = "stage_dead-letter"

  tags = {
    Environment = "stage"
  }
}

resource "aws_iam_policy" "sqs-stage" {
  name = "sqs-stage"
  policy = data.template_file.queue-stage.rendered
}
