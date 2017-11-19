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
