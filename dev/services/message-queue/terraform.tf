terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.6"

  cloud {
    organization = "datacite-ng"

    workspaces {
      name = "dev-services-message-queue"
    }
  }
}
