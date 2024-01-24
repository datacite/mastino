module "datacite_queues" {
  source = "../../../modules/datacite_queues"

  environment = "development"

  tags = {
    Environment = "dev"
  }
}