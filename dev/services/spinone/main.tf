resource "kubernetes_pod" "spinone" {
  metadata {
    name = "spinone"
    labels {
      app = "spinone"
    }
  }

  spec {
    container {
      image = "datacite/spinone"
      name  = "spinone"
      env   = [
        {
          name = "SOLR_URL"
          value = "${var.solr_url}"
        }
      ]
    }
  }
}

resource "kubernetes_service" "spinone" {
  metadata {
    name = "spinone"
  }
  spec {
    selector {
      app = "${kubernetes_pod.spinone.metadata.0.labels.app}"
    }

    port {
      port = "${var.service_port}"
      target_port = 80
    }

    type = "NodePort"
  }
}
