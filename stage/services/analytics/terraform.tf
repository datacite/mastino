terraform {
  required_version = ">= 0.12.31"

  backend "atlas" {
    name         = "datacite-ng/stage-services-analytics"
  }
}
