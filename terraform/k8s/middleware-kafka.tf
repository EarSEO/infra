resource "kubernetes_namespace" "kafka" {
  metadata {
    annotations = {
      name = "kafka"
    }

    name = "kafka"
  }
}

resource "helm_release" "kafka" {
  name       = "kafka"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.2"
  namespace  = "argocd"

  values = [
    yamlencode({
      applications = {
        kafka = {
          namespace = "argocd"
          project   = "default"
          sources = [
            {
              chart          = "strimzi-kafka-operator"
              repoURL        = "https://strimzi.io/charts/"
              targetRevision = "0.48.0"
              helm = {
                valueFiles = [
                  "$values/k8s-manifests/middleware/kafka/strimzi-operator.yaml",
                ]
              }
            },
            {
              repoURL        = "https://github.com/earseo/infra.git"
              targetRevision = "develop"
              path           = "k8s-manifests/middleware/kafka/resources"
            },
            {
              repoURL        = "https://github.com/earseo/infra.git"
              targetRevision = "develop"
              ref            = "values"
            },
          ]
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = kubernetes_namespace.kafka.metadata[0].name
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
    kubernetes_namespace.kafka,
    kubernetes_manifest.local_path_provisioner,
  ]
}
