module "datacite_queues" {
  source = "../../../modules/datacite_queues"

  environment = "development"

  tags = {
    Environment = "dev"
  }
}

# This should not be defined here as it's used by test
resource "aws_sqs_queue" "lupo-testing" {
  name                      = "test_lupo"
  redrive_policy            = jsonencode({
    deadLetterTargetArn = module.datacite_queues.dead_letter_arn
    maxReceiveCount     = 4
  })

  tags = {
    Environment = "dev"
  }
}