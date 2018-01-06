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
      port = "${var.service_port}"
      target_port = 80
    }

    type = "NodePort"
  }
}
