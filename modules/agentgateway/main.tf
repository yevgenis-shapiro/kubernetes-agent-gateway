
resource "helm_release" "kgateway_crds" {
  name              = "kgateway-crds"
  namespace         = "kgateway-system"
  create_namespace  = true

  chart   = "oci://cr.kgateway.dev/kgateway-dev/charts/kgateway-crds"
  version = "v2.1.1"

  wait            = true
  atomic          = true
  cleanup_on_fail = true
  timeout         = 300

}

resource "helm_release" "agentgateway" {
  depends_on = [helm_release.kgateway_crds]

  name             = "agentgateway"
  repository       = "https://kgateway.github.io/helm-charts"
  chart            = "agentgateway"
  namespace        = "kgateway"
  create_namespace = true

  depends_on = [
    null_resource.gateway_api_crds,
    helm_release.kgateway_crds
  ]
}
