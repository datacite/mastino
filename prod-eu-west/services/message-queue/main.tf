module "datacite_queues" {
  source = "../../../modules/datacite_queues"

  environment = "production"

  tags = {
    Environment = "production"
  }
}

moved {
  from = aws_sqs_queue.doi
  to   = module.datacite_queues.aws_sqs_queue.doi
}

moved {
  from = aws_sqs_queue.event
  to   = module.datacite_queues.aws_sqs_queue.event
}

moved {
  from = aws_sqs_queue.volpino
  to   = module.datacite_queues.aws_sqs_queue.volpino
}

moved {
  from = aws_sqs_queue.lupo
  to   = module.datacite_queues.aws_sqs_queue.lupo
}

moved {
  from = aws_sqs_queue.lupo-background
  to   = module.datacite_queues.aws_sqs_queue.lupo_background
}

moved {
  from = aws_sqs_queue.lupo-import
  to   = module.datacite_queues.aws_sqs_queue.lupo_import
}

moved {
  from = aws_sqs_queue.lupo-import-other-doi
  to   = module.datacite_queues.aws_sqs_queue.lupo_import_other_doi
}

moved {
  from = aws_sqs_queue.lupo-transfer
  to   = module.datacite_queues.aws_sqs_queue.lupo_transfer
}

moved {
  from = aws_sqs_queue.levriero
  to   = module.datacite_queues.aws_sqs_queue.levriero
}

moved {
  from = aws_sqs_queue.levriero-usage
  to   = module.datacite_queues.aws_sqs_queue.levriero_usage
}

moved {
  from = aws_sqs_queue.usage
  to   = module.datacite_queues.aws_sqs_queue.usage
}

moved {
  from = aws_sqs_queue.sashimi
  to   = module.datacite_queues.aws_sqs_queue.sashimi
}

moved {
  from = aws_sqs_queue.salesforce
  to   = module.datacite_queues.aws_sqs_queue.salesforce
}

moved {
  from = aws_sqs_queue.analytics
  to   = module.datacite_queues.aws_sqs_queue.analytics
}

moved {
  from = aws_sqs_queue.dead-letter
  to   = module.datacite_queues.aws_sqs_queue.dead-letter
}

resource "aws_iam_policy" "sqs" {
  name = "sqs"
  policy = data.template_file.queue.rendered
}
