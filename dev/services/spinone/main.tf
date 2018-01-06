resource "docker_image" "spinone" {
  name          = "${data.docker_registry_image.spinone.name}"
  pull_triggers = ["${data.docker_registry_image.spinone.sha256_digest}"]
}

resource "docker_container" "spinone" {
  name  = "mastino_spinone"
  hostname = "spinone"
  image = "${docker_image.spinone.latest}"
  restart= "always"
  must_run="true"
  ports = {
    internal = 80
    external = 8040
  }
  volumes = [
    {
      host_path = "${data.external.repo.result.path}/spinone/app"
      container_path = "/home/app/webapp/app"
    },
    {
      host_path = "${data.external.repo.result.path}/spinone/config"
      container_path = "/home/app/webapp/config"
    },
    {
      host_path = "${data.external.repo.result.path}/spinone/spec"
      container_path = "/home/app/webapp/spec"
    }
  ]
}
