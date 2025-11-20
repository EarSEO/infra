data "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

locals {
  github_secrets_raw = file("../../k8s-secret-manifests/argocd/argocd_github_secret.yaml")
  github_secrets = [
    for doc in split("---", local.github_secrets_raw) :
    yamldecode(doc)
    if trimspace(doc) != ""
  ]
}

resource "kubernetes_manifest" "argocd-github-access" {
  for_each = {
    for idx, secret in local.github_secrets :
    secret.metadata.name => secret
  }

  manifest = each.value

  computed_fields = [
    "data",
    "stringData"
  ]

  depends_on = [
    data.kubernetes_namespace.argocd
  ]
}

