terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5"
    }
  }

  required_version = ">= 1.6"

  cloud {
    organization = "datacite-ng"

    workspaces {
      name = "stage-services-schema"
    }
  }
}
