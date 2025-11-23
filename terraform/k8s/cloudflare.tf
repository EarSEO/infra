resource "helm_release" "cloudflare_tunnel" {
  name       = "cloudflare-tunnel"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.2"
  namespace  = "argocd"

  values = [
    yamlencode({
      applications = {
        cloudflare-tunnel = {
          namespace = "argocd"
          project   = "default"
          sources = [
            {
              chart          = "cloudflared"
              repoURL        = "https://community-charts.github.io/helm-charts/"
              targetRevision = "2.2.4"
              helm = {
                valueFiles = [
                  "$values/k8s-manifests/cloudflare/cloudflared.yaml",
                  "$secrets/cloudflare/cloudflared-secret.yaml",
                ]
              }
            },
            {
              repoURL        = "https://github.com/earseo/infra.git"
              targetRevision = "develop"
              ref            = "values"
            },
            {
              repoURL        = "https://github.com/earseo/infra-secret-manifests.git"
              targetRevision = "develop"
              ref            = "secrets"
            },
          ]
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "cloudflared"
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
            syncOptions = [
              "CreateNamespace=true",
              "RespectIgnoreDifferences=true",
            ]
          }
        }
      }
    })
  ]

  depends_on = [
    kubernetes_manifest.argocd-github-access,
    kubernetes_manifest.local_path_provisioner,
  ]
}
