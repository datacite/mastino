resource "kubernetes_pod" "api" {
  metadata {
    name = "api"
    labels {
      app = "api"
    }
  }

  spec {
    container {
      image = "datacite/spinone:latest"
      name  = "api"
      env   = [
        {
          name = "SOLR_URL"
          value = "${var.solr-url}"
        }
      ]
    }
  }
}

resource "kubernetes_service" "api" {
  metadata {
    name = "api"
  }
  spec {
    selector {
      app = "${kubernetes_pod.api.metadata.0.labels.app}"
    }

    port {
      port = "${var.service-ports["api"]}"
      target_port = 80
    }

    type = "NodePort"
  }
}

resource "kubernetes_replication_controller" "api" {
  metadata {
    name = "api"
    labels {
      app = "api"
    }
  }

  spec {
    replicas = "1"
    selector {
      app = "api"
    }
    template {
      container {
        name  = "api"
        image = "datacite/spinone:latest"
        env   = [
          {
            name = "SOLR_URL"
            value = "${var.solr-url}"
          }
        ]

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
