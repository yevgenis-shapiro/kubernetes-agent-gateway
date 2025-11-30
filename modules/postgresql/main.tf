
resource "helm_release" "postgresql_ha" {
  name       = "postgresql-ha"
  namespace  = "default"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql-ha"
  version    = "15.0.0" # check latest stable version

  create_namespace = true

  values = [
    yamlencode({
      global = {
        postgresql = {
          username = "postgres"
          password = "postgres" # ⚠️ move to terraform.tfvars or secret store
          database = "yevgeni"
        }
      }

      persistence = {
        enabled = true
        size    = "20Gi"
      }

      postgresql = {
        replicaCount = 1
      }

      pgpool = {
        replicaCount = 2
        service = {
          type = "ClusterIP" # or LoadBalancer / NodePort
        }
      }

      resources = {
        requests = {
          memory = "512Mi"
          cpu    = "250m"
        }
        limits = {
          memory = "1Gi"
          cpu    = "1000m"
        }
      }
    })
  ]
}


