module "datacite_queues" {
  source = "../../../modules/datacite_queues"

  environment = "stage"

  tags = {
    Environment = "stage"
  }
}

moved {
  from = aws_sqs_queue.doi-stage
  to   = module.datacite_queues.aws_sqs_queue.doi
}

moved {
  from = aws_sqs_queue.event-stage
  to   = module.datacite_queues.aws_sqs_queue.event
}

moved {
  from = aws_sqs_queue.volpino-stage
  to   = module.datacite_queues.aws_sqs_queue.volpino
}

moved {
  from = aws_sqs_queue.lupo-stage
  to   = module.datacite_queues.aws_sqs_queue.lupo
}

moved {
  from = aws_sqs_queue.lupo-background-stage
  to   = module.datacite_queues.aws_sqs_queue.lupo_background
}

moved {
  from = aws_sqs_queue.lupo-import-stage
  to   = module.datacite_queues.aws_sqs_queue.lupo_import
}

moved {
  from = aws_sqs_queue.lupo-import-other-doi-stage
  to   = module.datacite_queues.aws_sqs_queue.lupo_import_other_doi
}

moved {
  from = aws_sqs_queue.lupo-transfer-stage
  to   = module.datacite_queues.aws_sqs_queue.lupo_transfer
}

moved {
  from = aws_sqs_queue.levriero-stage
  to   = module.datacite_queues.aws_sqs_queue.levriero
}

moved {
  from = aws_sqs_queue.levriero-usage-stage
  to   = module.datacite_queues.aws_sqs_queue.levriero_usage
}

moved {
  from = aws_sqs_queue.usage-stage
  to   = module.datacite_queues.aws_sqs_queue.usage
}

moved {
  from = aws_sqs_queue.sashimi-stage
  to   = module.datacite_queues.aws_sqs_queue.sashimi
}

moved {
  from = aws_sqs_queue.salesforce-stage
  to   = module.datacite_queues.aws_sqs_queue.salesforce
}

moved {
  from = aws_sqs_queue.analytics
  to   = module.datacite_queues.aws_sqs_queue.analytics
}

moved {
  from = aws_sqs_queue.dead-letter-stage
  to   = module.datacite_queues.aws_sqs_queue.dead-letter
}

resource "aws_iam_policy" "sqs-stage" {
  name = "sqs-stage"
  policy = data.template_file.queue-stage.rendered
}
