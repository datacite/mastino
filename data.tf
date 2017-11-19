resource "kubernetes_service" "data" {
  metadata {
    name = "data"
  }
  spec {
    selector {
      app = "${kubernetes_pod.data.metadata.0.labels.app}"
    }
    session_affinity = "ClientIP"
    port {
      port = 8021
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_pod" "data" {
  metadata {
    name = "data"
  }

  spec {
    container {
      image = "crosscite/content-negotiation:latest"
      name  = "data"
    }
  }
}
