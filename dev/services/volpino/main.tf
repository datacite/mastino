resource "kubernetes_pod" "volpino" {
  metadata {
    name = "volpino"
    labels {
      app = "volpino"
    }
  }

  spec {
    container {
      image = "datacite/volpino"
      name  = "volpino"
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
          name = "JWT_PRIVATE_KEY"
          value = "${var.jwt_private_key}"
        },
        {
          name = "JWT_PUBLIC_KEY"
          value = "${var.jwt_public_key}"
        },
        {
          name = "SECRET_KEY_BASE"
          value = "${var.secret_key_base}"
        }
      ]
    }
  }
}

resource "kubernetes_service" "volpino" {
  metadata {
    name = "volpino"
  }
  spec {
    selector {
      app = "${kubernetes_pod.volpino.metadata.0.labels.app}"
    }

    port {
      port = "${var.service_port}"
      target_port = 80
    }

    type = "NodePort"
  }
}
