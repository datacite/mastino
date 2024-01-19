terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5"
    }
  }

  required_version = ">= 1.6"

  backend "atlas" {
    name         = "datacite-ng/stage-services-re3data"
  }
}
