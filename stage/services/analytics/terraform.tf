terraform {
  required_version = ">= 0.15.1"

  backend "atlas" {
    name         = "datacite-ng/stage-services-analytics"
  }
}
