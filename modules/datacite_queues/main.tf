resource "aws_sqs_queue" "doi" {
  name = "${var.environment}_doi"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })
  tags = var.tags
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_sqs_queue" "volpino" {
  name = "${var.environment}_volpino"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })
  visibility_timeout_seconds = 120
  tags                       = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_sqs_queue" "lupo" {
  name = "${var.environment}_lupo"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })
  visibility_timeout_seconds = 120
  tags                       = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_sqs_queue" "lupo_background" {
  name = "${var.environment}_lupo_background"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })
  visibility_timeout_seconds = 3600
  tags                       = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_sqs_queue" "lupo_import" {
  name = "${var.environment}_lupo_import"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })
  visibility_timeout_seconds = 3600
  tags                       = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_sqs_queue" "lupo_queue_batches_datacite_doi" {
  name = "${var.environment}_lupo_queue_batches_datacite_doi"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.queue_batches_datacite_doi-dead-letter.arn
    maxReceiveCount     = 4
  })
  visibility_timeout_seconds = 300
  tags                       = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_sqs_queue" "lupo_queue_batches_other_doi" {
  name = "${var.environment}_lupo_queue_batches_other_doi"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.queue_batches_other_doi-dead-letter.arn
    maxReceiveCount     = 4
  })
  visibility_timeout_seconds = 300
  tags                       = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_sqs_queue" "lupo_import_other_doi" {
  name = "${var.environment}_lupo_import_other_doi"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })
  visibility_timeout_seconds = 3600
  tags                       = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_sqs_queue" "lupo_transfer" {
  name = "${var.environment}_lupo_transfer"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })
  visibility_timeout_seconds = 3600

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_sqs_queue" "lupo_doi_registration" {
  name = "${var.environment}_lupo_doi_registration"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })
  visibility_timeout_seconds = 3600
  tags                       = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

// Queue for lupo support tasks.
resource "aws_sqs_queue" "lupo_support" {
  name = "${var.environment}_lupo_support"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.lupo_support-dead-letter.arn
    maxReceiveCount     = 1
  })
  visibility_timeout_seconds = 3600
  tags                       = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

// Unique dead letter queue for lupo support tasks
resource "aws_sqs_queue" "lupo_support-dead-letter" {
  name = "${var.environment}_lupo_support_dead-letter"
  tags = var.tags
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_sqs_queue" "levriero" {
  name = "${var.environment}_levriero"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_sqs_queue" "levriero_usage" {
  name = "${var.environment}_levriero_usage"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_sqs_queue" "sashimi" {
  name = "${var.environment}_sashimi"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_sqs_queue" "usage" {
  name = "${var.environment}_usage"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_sqs_queue" "salesforce" {
  name                       = "${var.environment}_salesforce"
  visibility_timeout_seconds = 120
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_sqs_queue" "analytics" {
  name = "${var.environment}_analytics"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_sqs_queue" "events" {
  name = "${var.environment}_events"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_sqs_queue" "events_index" {
  name = "${var.environment}_events_index"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter.arn
    maxReceiveCount     = 4
  })

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

// BatchQueing dead letter queue OtherDois 
resource "aws_sqs_queue" "queue_batches_other_doi-dead-letter" {
  name = "${var.environment}_queue_batches_other_doi-dead-letter"

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

// BatchQueing dead letter queue - DataCite Dois
resource "aws_sqs_queue" "queue_batches_datacite_doi-dead-letter" {
  name = "${var.environment}_queue_batches_datacite_doi-dead-letter"

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}
// Shared dead letter queue
resource "aws_sqs_queue" "dead-letter" {
  name = "${var.environment}_dead-letter"

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}
