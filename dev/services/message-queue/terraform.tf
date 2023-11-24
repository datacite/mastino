terraform {
  required_version = ">= 0.12"

  backend "atlas" {
    name         = "datacite-ng/dev-services-message-queue"
  }
}
