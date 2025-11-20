resource "kubernetes_namespace" "postgres" {
  metadata {
    annotations = {
      name = "postgres"
    }

    name = "postgres"
  }
}

resource "helm_release" "postgres" {
  name       = "postgres"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.2"
  namespace  = "argocd"

  values = [
    yamlencode({
      applications = {
        postgres = {
          namespace = "argocd"
          project   = "default"
          sources = [
            {
              repoURL        = "https://github.com/earseo/infra.git"
              targetRevision = "develop"
              path           = "k8s-manifests/middleware/postgres"
            },
            {
              repoURL        = "https://github.com/earseo/infra-secret-manifests.git"
              targetRevision = "develop"
              path           = "middleware/postgres"
            },
          ]
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = kubernetes_namespace.postgres.metadata[0].name
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
    kubernetes_namespace.postgres,
    kubernetes_manifest.local_path_provisioner,
  ]
}
