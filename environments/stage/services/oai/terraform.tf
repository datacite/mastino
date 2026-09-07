terraform {
  cloud {
    organization = "datacite-ng"
    workspaces {
      tags = ["stage", "app:oai"]
    }
  }
}