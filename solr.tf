resource "mysql_database" "solr" {
  name = "${var.mysql-databases["solr"]}"
}

resource "kubernetes_pod" "solr" {
  metadata {
    name = "solr"
    labels {
      app = "solr"
    }
  }

  spec {
    container {
      image = "datacite/search:stable"
      name  = "solr"
      env   = [
        {
          name = "DB_NAME"
          value = "${var.mysql-databases["solr"]}"
        },
        {
          name = "DB_USERNAME"
          value = "${var.mysql_user}"
        },
        {
          name = "DB_USER"
          value = "${var.mysql_user}"
        },
        {
          name = "DB_PASSWORD"
          value = "${var.mysql_password}"
        },
        {
          name = "MYSQL_ALLOW_EMPTY_PASSWORD"
          value = "${var.mysql_allow_empty_password}"
        }
      ]
      volume_mount = {
        name = "solr-persistent-storage"
        mount_path = "/root/.m2"
      }
    }
    volume {
      name = "solr-persistent-storage"
      persistent_volume_claim {
        claim_name = "solr-pv-claim"
      }
    }
  }
}

resource "kubernetes_service" "solr" {
  metadata {
    name = "solr"
  }
  spec {
    selector {
      app = "${kubernetes_pod.solr.metadata.0.labels.app}"
    }

    port {
      port = "${var.service-ports["solr"]}"
      target_port = 8080
    }

    type = "NodePort"
  }
}

resource "kubernetes_replication_controller" "solr" {
  metadata {
    name = "solr"
    labels {
      app = "solr"
    }
  }

  spec {
    replicas = "1"
    selector {
      app = "solr"
    }
    template {
      container {
        name  = "solr"
        image = "datacite/search:stable"

        resources{
          limits{
            cpu    = "0.5"
            memory = "512Mi"
          }
        }
        env   = [
          {
            name = "DB_HOST"
            value = "${var.mysql_host}"
          },
          {
            name = "DB_NAME"
            value = "${var.mysql-databases["solr"]}"
          },
          {
            name = "DB_USERNAME"
            value = "${var.mysql_user}"
          },
          {
            name = "DB_USER"
            value = "${var.mysql_user}"
          },
          {
            name = "DB_PASSWORD"
            value = "${var.mysql_password}"
          },
          {
            name = "MYSQL_ALLOW_EMPTY_PASSWORD"
            value = "${var.mysql_allow_empty_password}"
          }
        ]
        volume_mount = {
          name = "solr-persistent-storage"
          mount_path = "/root/.m2"
        }
      }
      volume {
        name = "solr-persistent-storage"
        persistent_volume_claim {
          claim_name = "solr-pv-claim"
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "solr" {
  metadata {
    name = "solr-pv-claim"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests {
        storage = "5Gi"
      }
    }
  }
}
