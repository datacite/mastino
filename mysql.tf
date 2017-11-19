resource "kubernetes_pod" "mysql" {
  metadata {
    name = "mysql"
  }

  spec {
    container {
      image = "mysql:5.7"
      name  = "mysql"
    }
  }
}

resource "kubernetes_persistent_volume_claim" "mysql" {
  metadata {
    name = "mysql"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests {
        storage = "5Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume.default.metadata.0.name}"
  }
}
