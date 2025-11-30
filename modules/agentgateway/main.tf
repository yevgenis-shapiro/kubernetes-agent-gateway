
resource "null_resource" "gateway_api_crds" {
  provisioner "local-exec" {
    command = <<-EOT
      kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/standard-install.yaml
      kubectl wait --for condition=established --timeout=90s crd/gatewayclasses.gateway.networking.k8s.io
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      kubectl delete -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/standard-install.yaml --ignore-not-found=true
    EOT
  }
}


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
