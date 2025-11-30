
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

  #depends_on = [null_resource.gateway_api_crds]
}


resource "helm_release" "kgateway" {
  name      = "kgateway"
  namespace = "kgateway-system"

  chart   = "oci://cr.kgateway.dev/kgateway-dev/charts/kgateway"
  version = "v2.1.1"
  wait            = true
  atomic          = true
  cleanup_on_fail = true
  timeout         = 600
  #values = [
  #  file("${path.module}/kgateway.yaml")
  #]

  set {
    name  = "agentgateway.enabled"
    value = "true"
  }

  set {
    name  = "controller.replicas"
    value = "2"
  }

  set {
    name  = "envoyProxy.service.type"
    value = "LoadBalancer"
  }

  depends_on = [
    null_resource.gateway_api_crds,
    helm_release.kgateway_crds
  ]
}
