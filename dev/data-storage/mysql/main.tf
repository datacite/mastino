resource "kubernetes_pod" "mysql" {
  metadata {
    name = "mysql"
    labels {
      app = "mysql"
    }
  }

  spec {
    container {
      image = "mysql:5.7"
      name  = "mysql"
      env   = [
        {
          name = "MYSQL_DATABASE"
          value = "${var.mysql_database}"
        },
        {
          name = "MYSQL_USER"
          value = "${var.mysql_user}"
        },
        {
          name = "MYSQL_PASSWORD"
          value = "${var.mysql_password}"
        },
        {
          name = "MYSQL_ALLOW_EMPTY_PASSWORD"
          value = "${var.mysql_allow_empty_password}"
        }
      ]
      volume_mount = {
        name = "mysql-persistent-storage"
        mount_path = "/var/lib/mysql"
      }
    }
    volume {
      name = "mysql-persistent-storage"
      persistent_volume_claim {
        claim_name = "mysql-pv-claim"
      }
    }
  }
}

resource "kubernetes_service" "mysql" {
  metadata {
    name = "mysql"
  }
  spec {
    selector {
      app = "${kubernetes_pod.mysql.metadata.0.labels.app}"
    }

    port {
      port = "${var.service_port}"
      target_port = 3306
    }

    type = "NodePort"
  }
}

resource "kubernetes_persistent_volume_claim" "mysql" {
  metadata {
    name = "mysql-pv-claim"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests {
        storage = "10Gi"
      }
    }
    /*volume_name = "${kubernetes_persistent_volume.default.metadata.0.name}"*/
  }
}

resource "kubernetes_replication_controller" "mysql" {
  metadata {
    name = "mysql"
    labels {
      app = "mysql"
    }
  }

  spec {
    replicas = "1"
    selector {
      app = "mysql"
    }
    template {
      container {
        name  = "data"
        image = "mysql:5.7"
        env   = [
          {
            name = "MYSQL_DATABASE"
            value = "${var.mysql_database}"
          },
          {
            name = "MYSQL_USER"
            value = "${var.mysql_user}"
          },
          {
            name = "MYSQL_PASSWORD"
            value = "${var.mysql_password}"
          },
          {
            name = "MYSQL_ALLOW_EMPTY_PASSWORD"
            value = "${var.mysql_allow_empty_password}"
          }
        ]
        volume_mount = {
          name = "mysql-persistent-storage"
          mount_path = "/var/lib/mysql"
        }
      }
      volume {
        name = "mysql-persistent-storage"
        persistent_volume_claim {
          claim_name = "mysql-pv-claim"
        }
      }
    }
  }
}
