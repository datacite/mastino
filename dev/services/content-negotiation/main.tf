resource "kubernetes_pod" "content-negotiation" {
  metadata {
    name = "content-negotiation"
    labels {
      app = "content-negotiation"
    }
  }

  spec {
    container {
      image = "crosscite/content-negotiation"
      name  = "content-negotiation"
    }
  }
}

resource "kubernetes_service" "content-negotiation" {
  metadata {
    name = "content-negotiation"
  }
  spec {
    selector {
      app = "${kubernetes_pod.content-negotiation.metadata.0.labels.app}"
    }

    port {
      port = "${var.service-port}"
      target_port = 80
    }

    type = "NodePort"
  }
}

resource "kubernetes_replication_controller" "content-negotiation" {
  metadata {
    name = "content-negotiation"
    labels {
      app = "content-negotiation"
    }
  }

  spec {
    replicas = "1"
    selector {
      app = "content-negotiation"
    }
    template {
      container {
        name  = "content-negotiation"
        image = "crosscite/content-negotiation"

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
