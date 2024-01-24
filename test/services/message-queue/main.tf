module "datacite_queues" {
  source = "../../../modules/datacite_queues"

  environment = "test"

  tags = {
    Environment = "test"
  }
}

moved {
  from = aws_sqs_queue.doi-test
  to   = module.datacite_queues.aws_sqs_queue.doi
}

moved {
  from = aws_sqs_queue.event-test
  to   = module.datacite_queues.aws_sqs_queue.event
}

moved {
  from = aws_sqs_queue.volpino-test
  to   = module.datacite_queues.aws_sqs_queue.volpino
}

moved {
  from = aws_sqs_queue.lupo-test
  to   = module.datacite_queues.aws_sqs_queue.lupo
}

moved {
  from = aws_sqs_queue.lupo-background-test
  to   = module.datacite_queues.aws_sqs_queue.lupo_background
}

moved {
  from = aws_sqs_queue.lupo-import-test
  to   = module.datacite_queues.aws_sqs_queue.lupo_import
}

moved {
  from = aws_sqs_queue.lupo-import-other-doi-test
  to   = module.datacite_queues.aws_sqs_queue.lupo_import_other_doi
}

moved {
  from = aws_sqs_queue.lupo-transfer-test
  to   = module.datacite_queues.aws_sqs_queue.lupo_transfer
}

moved {
  from = aws_sqs_queue.levriero-test
  to   = module.datacite_queues.aws_sqs_queue.levriero
}

moved {
  from = aws_sqs_queue.levriero-usage-test
  to   = module.datacite_queues.aws_sqs_queue.levriero_usage
}

moved {
  from = aws_sqs_queue.usage-test
  to   = module.datacite_queues.aws_sqs_queue.usage
}

moved {
  from = aws_sqs_queue.sashimi-test
  to   = module.datacite_queues.aws_sqs_queue.sashimi
}

moved {
  from = aws_sqs_queue.analytics
  to   = module.datacite_queues.aws_sqs_queue.analytics
}

moved {
  from = aws_sqs_queue.dead-letter-test
  to   = module.datacite_queues.aws_sqs_queue.dead-letter
}

resource "aws_iam_policy" "sqs-test" {
  name = "sqs-test"
  policy = data.template_file.queue-test.rendered
}
