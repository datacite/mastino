/*resource "mysql_database" "search" {
  name = "${var.mysql-databases["search"]}"
}*/

resource "kubernetes_pod" "search" {
  metadata {
    name = "search"
    labels {
      app = "search"
    }
  }

  spec {
    container {
      image = "datacite/search:test_rolled_back"
      name  = "search"
      env   = [
        {
          name = "DB_HOST"
          value = "${var.mysql_host}"
        },
        {
          name = "DB_NAME"
          value = "${var.mysql_database}"
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
        },
        {
          name = "SOLR_USER"
          value = "${var.solr_user}"
        },
        {
          name = "SOLR_PASSWORD"
          value = "${var.solr_password}"
        }
      ]
      volume_mount = {
        name = "search-persistent-storage"
        mount_path = "/root/.m2"
      }
    }
    volume {
      name = "search-persistent-storage"
      persistent_volume_claim {
        claim_name = "search-pv-claim"
      }
    }
  }
}

resource "kubernetes_service" "search" {
  metadata {
    name = "search"
  }
  spec {
    selector {
      app = "${kubernetes_pod.search.metadata.0.labels.app}"
    }

    port {
      port = "${var.service_port}"
      target_port = 80
    }

    type = "NodePort"
  }
}

resource "kubernetes_persistent_volume_claim" "search" {
  metadata {
    name = "search-pv-claim"
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
