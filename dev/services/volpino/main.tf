resource "docker_image" "volpino" {
  name          = "${data.docker_registry_image.volpino.name}"
  pull_triggers = ["${data.docker_registry_image.volpino.sha256_digest}"]
}

resource "docker_container" "volpino" {
  name  = "mastino_volpino"
  hostname = "volpino"
  image = "${docker_image.volpino.latest}"
  restart= "always"
  must_run="true"
  ports = {
    internal = 80
    external = 8080
  }
  volumes = [
    {
      host_path = "${data.external.repo.result.path}/volpino/app"
      container_path = "/home/app/webapp/app"
    },
    {
      host_path = "${data.external.repo.result.path}/volpino/config"
      container_path = "/home/app/webapp/config"
    },
    {
      host_path = "${data.external.repo.result.path}/volpino/spec"
      container_path = "/home/app/webapp/spec"
    }
  ],
  env = [
    "MYSQL_DATABASE=volpino",
    "MYSQL_USER=${var.mysql_user}",
    "MYSQL_PASSWORD=${var.mysql_password}"
  ]
}
