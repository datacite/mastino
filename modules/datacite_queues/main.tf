locals {
  queue_names = [
      "doi",
      "event",
      "volpino",
      "lupo",
      "lupo_background",
      "lupo_import",
      "lupo_import_other_doi",
      "lupo_transfer",
      "levriero",
      "levriero_usage",
      "sashimi",
      "usage",
      "salesforce",
      "analytics",
  ]
}


resource "aws_sqs_queue" "dead-letter" {
  name = "${var.environment}_dead-letter"

  tags = var.tags
}

resource "aws_sqs_queue" "queue" {
  for_each = toset(local.queue_names)

  name = "${var.environment}_${each.value}"

  redrive_policy            = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })

  tags = var.tags
}
