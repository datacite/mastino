resource "docker_image" "lupo" {
  name          = "${data.docker_registry_image.lupo.name}"
  pull_triggers = ["${data.docker_registry_image.lupo.sha256_digest}"]
}

resource "docker_container" "lupo" {
  name  = "lupo"
  hostname = "lupo"
  image = "${docker_image.lupo.latest}"
  restart= "always"
  must_run="true"
  ports = {
    internal = 80
    external = 8060
  }
  volumes = [
    {
      host_path = "${data.external.repo.result.path}/lupo/app"
      container_path = "/home/app/webapp/app"
    },
    {
      host_path = "${data.external.repo.result.path}/lupo/config"
      container_path = "/home/app/webapp/config"
    },
    {
      host_path = "${data.external.repo.result.path}/lupo/spec"
      container_path = "/home/app/webapp/spec"
    }
  ],
  env = [
    "MYSQL_DATABASE=lupo",
    "MYSQL_USER=${var.mysql_user}",
    "MYSQL_PASSWORD=${var.mysql_password}"
  ]
}
