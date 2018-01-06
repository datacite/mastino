provider "docker" {
  version    = "~> 0.1"
}

provider "external" {
  version    = "~> 1.0"
}

data "docker_registry_image" "spinone" {
  name = "datacite/spinone"
}

data "external" "repo" {
  program = ["ruby", "${path.module}/repo.rb"]
}
