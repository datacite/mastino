resource "kubernetes_pod" "lupo" {
  metadata {
    name = "lupo"
    labels {
      app = "lupo"
    }
  }

  spec {
    container {
      image = "datacite/lupo"
      name  = "lupo"
      env   = [
        {
          name = "MYSQL_HOST"
          value = "${var.mysql_host}"
        },
        {
          name = "MYSQL_DATABASE"
          value = "${var.mysql_database}"
        },
        {
          name = "MYSQL_USER"
          value = "${var.mysql_user}"
        },
        {
          name = "MYSQL_PASSWORD"
          value = "${var.mysql_password}"
        },
        {
          name = "MODE"
          value = "datacite"
        },
        {
          name = "JWT_PRIVATE_KEY"
          value = "${var.jwt_private_key}"
        },
        {
          name = "JWT_PUBLIC_KEY"
          value = "${var.jwt_public_key}"
        }
      ]
    }
  }
}

resource "kubernetes_service" "lupo" {
  metadata {
    name = "lupo"
  }
  spec {
    selector {
      app = "${kubernetes_pod.lupo.metadata.0.labels.app}"
    }

    port {
      port = "${var.service_port}"
      target_port = 80
    }

    type = "NodePort"
  }
}
