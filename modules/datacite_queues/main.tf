resource "aws_sqs_queue" "doi" {
  name = "${var.environment}_doi"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })
  tags = var.tags
}

resource "aws_sqs_queue" "event" {
  name = "${var.environment}_event"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })
  tags = var.tags
}

resource "aws_sqs_queue" "volpino" {
  name = "${var.environment}_volpino"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })
  visibility_timeout_seconds = 120
  tags = var.tags
}

resource "aws_sqs_queue" "lupo" {
  name = "${var.environment}_lupo"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })
  visibility_timeout_seconds = 120
  tags = var.tags
}

resource "aws_sqs_queue" "lupo_background" {
  name = "${var.environment}_lupo_background"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })
  visibility_timeout_seconds = 3600
  tags = var.tags
}

resource "aws_sqs_queue" "lupo_import" {
  name = "${var.environment}_lupo_import"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })
  visibility_timeout_seconds = 3600
  tags = var.tags
}

resource "aws_sqs_queue" "lupo_import_other_doi" {
  name = "${var.environment}_lupo_import_other_doi"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })
  visibility_timeout_seconds = 3600
  tags = var.tags
}

resource "aws_sqs_queue" "lupo_transfer" {
  name = "${var.environment}_lupo_transfer"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })

  tags = var.tags
}

resource "aws_sqs_queue" "levriero" {
  name = "${var.environment}_levriero"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })

  tags = var.tags
}

resource "aws_sqs_queue" "levriero_usage" {
  name = "${var.environment}_levriero_usage"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })

  tags = var.tags
}

resource "aws_sqs_queue" "sashimi" {
  name = "${var.environment}_sashimi"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })

  tags = var.tags
}

resource "aws_sqs_queue" "usage" {
  name = "${var.environment}_usage"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })

  tags = var.tags
}

resource "aws_sqs_queue" "salesforce" {
  name = "${var.environment}_salesforce"
  visibility_timeout_seconds = 120
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })

  tags = var.tags
}

resource "aws_sqs_queue" "analytics" {
  name = "${var.environment}_analytics"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })

  tags = var.tags
}

// Shared dead letter queue
resource "aws_sqs_queue" "dead-letter" {
  name = "${var.environment}_dead-letter"

  tags = var.tags
}

moved {
  from = aws_sqs_queue.queue["doi"]
  to   = aws_sqs_queue.doi
}

moved {
  from = aws_sqs_queue.queue["event"]
  to   = aws_sqs_queue.event
}

moved {
  from = aws_sqs_queue.queue["volpino"]
  to   = aws_sqs_queue.volpino
}

moved {
  from = aws_sqs_queue.queue["lupo"]
  to   = aws_sqs_queue.lupo
}

moved {
  from = aws_sqs_queue.queue["lupo_background"]
  to   = aws_sqs_queue.lupo_background
}

moved {
  from = aws_sqs_queue.queue["lupo_import"]
  to   = aws_sqs_queue.lupo_import
}

moved {
  from = aws_sqs_queue.queue["lupo_import_other_doi"]
  to   = aws_sqs_queue.lupo_import_other_doi
}

moved {
  from = aws_sqs_queue.queue["lupo_transfer"]
  to   = aws_sqs_queue.lupo_transfer
}

moved {
  from = aws_sqs_queue.queue["levriero"]
  to   = aws_sqs_queue.levriero
}

moved {
  from = aws_sqs_queue.queue["levriero_usage"]
  to   = aws_sqs_queue.levriero_usage
}

moved {
  from = aws_sqs_queue.queue["sashimi"]
  to   = aws_sqs_queue.sashimi
}

moved {
  from = aws_sqs_queue.queue["usage"]
  to   = aws_sqs_queue.usage
}

moved {
  from = aws_sqs_queue.queue["salesforce"]
  to   = aws_sqs_queue.salesforce
}

moved {
  from = aws_sqs_queue.queue["analytics"]
  to   = aws_sqs_queue.analytics
}