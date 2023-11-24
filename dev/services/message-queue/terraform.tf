terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
    template = {
      source = "hashicorp/template"
    }
  }

  required_version = ">= 0.13"

  backend "atlas" {
    name         = "datacite-ng/dev-services-message-queue"
  }
}
