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
          value = "${var.solr-url}"
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
      port = "${var.service-port}"
      target_port = 80
    }

    type = "NodePort"
  }
}

resource "kubernetes_replication_controller" "spinone" {
  metadata {
    name = "spinone"
    labels {
      app = "spinone"
    }
  }

  spec {
    replicas = "1"
    selector {
      app = "spinone"
    }
    template {
      container {
        name  = "spinone"
        image = "datacite/spinone"
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
