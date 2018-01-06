resource "kubernetes_pod" "cheetoh" {
  metadata {
    name = "cheetoh"
    labels {
      app = "cheetoh"
    }
  }

  spec {
    container {
      image = "datacite/cheetoh"
      name  = "cheetoh"
    }
  }
}

resource "kubernetes_service" "cheetoh" {
  metadata {
    name = "cheetoh"
  }
  spec {
    selector {
      app = "${kubernetes_pod.cheetoh.metadata.0.labels.app}"
    }

    port {
      port = "${var.service-port}"
      target_port = 80
    }

    type = "NodePort"
  }
}

resource "kubernetes_replication_controller" "cheetoh" {
  metadata {
    name = "cheetoh"
    labels {
      app = "cheetoh"
    }
  }

  spec {
    replicas = "1"
    selector {
      app = "cheetoh"
    }
    template {
      container {
        image = "datacite/cheetoh"
        name  = "cheetoh"

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
