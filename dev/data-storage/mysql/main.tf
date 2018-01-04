resource "docker_image" "mysql" {
  name          = "${data.docker_registry_image.mysql.name}"
  pull_triggers = ["${data.docker_registry_image.mysql.sha256_digest}"]
}

resource "docker_container" "mysql" {
  name  = "mysql"
  hostname = "mysql"
  image = "${docker_image.mysql.latest}"
  restart= "always"
  must_run="true"
  env = ["MYSQL_DATABASE=mysql", "MYSQL_USER=${var.mysql_user}", "MYSQL_ALLOW_EMPTY_PASSWORD=${var.mysql_allow_empty_password}"]
}
