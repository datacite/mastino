/*resource "mysql_database" "volpino" {
  name = "${var.mysql-databases["volpino"]}"
}*/

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
          value = "${var.mysql-databases["volpino"]}"
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

resource "kubernetes_service" "volpino" {
  metadata {
    name = "volpino"
  }
  spec {
    selector {
      app = "${kubernetes_pod.volpino.metadata.0.labels.app}"
    }

    port {
      port = "${var.service-ports["volpino"]}"
      target_port = 80
    }

    type = "NodePort"
  }
}

resource "kubernetes_replication_controller" "volpino" {
  metadata {
    name = "volpino"
    labels {
      app = "volpino"
    }
  }

  spec {
    replicas = "1"
    selector {
      app = "volpino"
    }
    template {
      container {
        name  = "volpino"
        image = "datacite/volpino"

        resources{
          limits{
            cpu    = "0.5"
            memory = "512Mi"
          }
        }
      }
    }
  }
}
