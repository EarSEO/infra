resource "kubernetes_namespace" "local_path_storage" {
  metadata {
    name = "local-path-storage"
  }
}

data "http" "local_path_provisioner" {
  url = "https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.32/deploy/local-path-storage.yaml"
}

locals {
  local_path_manifests = [
    for manifest in split("---", data.http.local_path_provisioner.response_body) :
    yamldecode(manifest)
    if trimspace(manifest) != ""
  ]
}

resource "kubernetes_manifest" "local_path_provisioner" {
  for_each = {
    for idx, manifest in local.local_path_manifests :
    "${manifest.kind}-${lookup(manifest.metadata, "name", idx)}" => manifest
    if manifest.kind != "Namespace"
  }

  manifest = each.value

  depends_on = [
    kubernetes_namespace.local_path_storage
  ]
}
