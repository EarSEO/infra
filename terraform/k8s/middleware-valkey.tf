resource "kubernetes_namespace" "valkey" {
  metadata {
    annotations = {
      name = "valkey"
    }

    name = "valkey"
  }
}

resource "helm_release" "valkey" {
  name       = "valkey"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.2"
  namespace  = "argocd"

  values = [
    yamlencode({
      applications = {
        valkey = {
          namespace = "argocd"
          project   = "default"
          sources = [
            {
              repoURL        = "https://github.com/earseo/infra.git"
              targetRevision = "develop"
              path           = "k8s-manifests/middleware/valkey"
            },
            {
              repoURL        = "https://github.com/earseo/infra-secret-manifests.git"
              targetRevision = "develop"
              path           = "middleware/valkey"
            },
          ]
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = kubernetes_namespace.valkey.metadata[0].name
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
            syncOptions = ["CreateNamespace=true"]
          }
        }
      }

    })
  ]

  depends_on = [
    kubernetes_manifest.argocd-github-access,
    kubernetes_namespace.valkey,
    kubernetes_manifest.local_path_provisioner,
  ]
}
