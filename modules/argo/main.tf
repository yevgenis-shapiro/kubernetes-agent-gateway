
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "8.5.3" # Check for latest version if needed
  create_namespace = true

  cleanup_on_fail = true
  dependency_update = true

  values = [
    file("${path.module}/argocd-values.yaml")
 ]
}

