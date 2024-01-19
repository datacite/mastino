terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5"
    }
  }

  required_version = ">= 0.13"

  backend "atlas" {
    name         = "datacite-ng/stage-services-re3data"
  }
}
