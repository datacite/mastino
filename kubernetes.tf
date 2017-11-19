provider "kubernetes" {
  version = "~> 1.0"
}

resource "kubernetes_persistent_volume" "default" {
    metadata {
        name = "default"
    }
    spec {
        capacity {
            storage = "20Gi"
        }
        access_modes = ["ReadWriteMany"]
        persistent_volume_source {
            vsphere_volume {
                volume_path = "/absolute/path"
            }
        }
    }
}
