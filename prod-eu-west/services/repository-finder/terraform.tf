terraform {
  required_version = ">= 0.11"

  backend "atlas" {
    name         = "datacite-ng/eu-prod-west-services-repository-finder"
  }
}
