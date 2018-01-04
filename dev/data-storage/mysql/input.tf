provider "docker" {
  version    = "~> 0.1"
}

data "docker_registry_image" "mysql" {
  name = "mysql:5.7"
}
