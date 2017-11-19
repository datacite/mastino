resource "kubernetes_pod" "profiles" {
  metadata {
    name = "profiles"
    labels {
      app = "profiles"
    }
  }

  spec {
    container {
      image = "datacite/volpino:latest"
      name  = "profiles"
      env   = [
        {
          name = "DB_HOST"
          value = "${var.mysql-host}"
        },
        {
          name = "DB_NAME"
          value = "${var.mysql-databases["profiles"]}"
        },
        {
          name = "DB_USERNAME"
          value = "${var.mysql-user}"
        },
        {
          name = "DB_PASSWORD"
          value = "${var.mysql-password}"
        },
        {
          name = "MODE"
          value = "datacite"
        }
      ]
    }
  }
}

resource "kubernetes_service" "profiles" {
  metadata {
    name = "profiles"
  }
  spec {
    selector {
      app = "${kubernetes_pod.profiles.metadata.0.labels.app}"
    }

    port {
      port = "${var.service-ports["profiles"]}"
      target_port = 80
    }

    type = "NodePort"
  }
}

resource "kubernetes_replication_controller" "profiles" {
  metadata {
    name = "profiles"
    labels {
      app = "profiles"
    }
  }

  spec {
    replicas = "1"
    selector {
      app = "profiles"
    }
    template {
      container {
        name  = "profiles"
        image = "datacite/volpino:latest"

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
