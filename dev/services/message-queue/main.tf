resource "aws_sqs_queue" "event-dev" {
  name                      = "development_event"
  redrive_policy            = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter-dev.arn
    maxReceiveCount     = 4
  })

  tags = {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "doi-dev" {
  name                      = "development_doi"
  redrive_policy            = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter-dev.arn
    maxReceiveCount     = 4
  })

  tags = {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "volpino-dev" {
  name                      = "development_volpino"
  redrive_policy            = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter-dev.arn
    maxReceiveCount     = 4
  })

  tags = {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "lupo-dev" {
  name                      = "development_lupo"
  redrive_policy            = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter-dev.arn
    maxReceiveCount     = 4
  })

  tags = {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "lupo-background-dev" {
  name                      = "development_lupo_background"
  redrive_policy            = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter-dev.arn
    maxReceiveCount     = 4
  })

  tags = {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "lupo-transfer-dev" {
  name                      = "development_lupo_transfer"
  redrive_policy            = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter-dev.arn
    maxReceiveCount     = 4
  })

  tags = {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "lupo-import-dev" {
  name                      = "development_lupo_import"
  redrive_policy            = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter-dev.arn
    maxReceiveCount     = 4
  })

  tags = {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "lupo-import-other-doi-dev" {
  name                      = "development_lupo_import_other_doi"
  redrive_policy            = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter-dev.arn
    maxReceiveCount     = 4
  })

  tags = {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "doi-testing" {
  name                      = "test_doi"
  redrive_policy            = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter-dev.arn
    maxReceiveCount     = 4
  })

  tags = {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "lupo-testing" {
  name                      = "test_lupo"
  redrive_policy            = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter-dev.arn
    maxReceiveCount     = 4
  })

  tags = {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "levriero-dev" {
  name                      = "development_levriero"
  redrive_policy            = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter-dev.arn
    maxReceiveCount     = 4
  })

  tags = {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "levriero-usage-dev" {
  name                      = "development_levriero_usage"
  redrive_policy            = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter-dev.arn
    maxReceiveCount     = 4
  })

  tags = {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "dead-letter-dev" {
  name                      = "development_dead-letter"

  tags = {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "sashimi-dev" {
  name                      = "development_sashimi"

  tags = {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "salesforce-dev" {
  name                      = "development_salesforce"

  tags = {
    Environment = "dev"
  }
}