terraform {
  required_version = ">= 0.11"

  backend "atlas" {
    name         = "datacite-ng/test-services-metrics-api"
  }
}
