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
      port = "${var.service_port}"
      target_port = 80
    }

    type = "NodePort"
  }
}
