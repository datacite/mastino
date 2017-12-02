resource "mysql_database" "profiles" {
  name = "${var.mysql-databases["profiles"]}"
}

resource "kubernetes_pod" "profiles" {
  metadata {
    name = "profiles"
    labels {
      app = "profiles"
    }
  }

  spec {
    container {
      image = "datacite/volpino:latest"
      name  = "profiles"
      env   = [
        {
          name = "MYSQL_HOST"
          value = "${var.mysql_host}"
        },
        {
          name = "MYSQL_DATABASE"
          value = "${var.mysql-databases["profiles"]}"
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
          name = "MODE"
          value = "datacite"
        },
        {
          name = "JWT_PRIVATE_KEY"
          value = "${var.jwt_private_key}"
        },
        {
          name = "JWT_PUBLIC_KEY"
          value = "${var.jwt_public_key}"
        }
      ]
    }
  }
}

resource "kubernetes_service" "profiles" {
  metadata {
    name = "profiles"
  }
  spec {
    selector {
      app = "${kubernetes_pod.profiles.metadata.0.labels.app}"
    }

    port {
      port = "${var.service-ports["profiles"]}"
      target_port = 80
    }

    type = "NodePort"
  }
}

resource "kubernetes_replication_controller" "profiles" {
  metadata {
    name = "profiles"
    labels {
      app = "profiles"
    }
  }

  spec {
    replicas = "1"
    selector {
      app = "profiles"
    }
    template {
      container {
        name  = "profiles"
        image = "datacite/volpino:latest"

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
