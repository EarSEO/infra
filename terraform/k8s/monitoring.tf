resource "kubernetes_namespace" "monitoring" {
  metadata {
    annotations = {
      name = "monitoring"
    }

    labels = {
      "argocd.argoproj.io/managed-by" = "argocd"
    }

    name = "monitoring"
  }
}

resource "helm_release" "prometheus_grafana" {
  name       = "prometheus-grafana"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.2"
  namespace  = "argocd"

  atomic            = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    yamlencode({
      applications = {
        prometheus-grafana = {
          namespace = "argocd"
          project   = "default"
          sources = [
            {
              chart          = "kube-prometheus-stack"
              repoURL        = "https://prometheus-community.github.io/helm-charts"
              targetRevision = "79.5.0"
              helm = {
                valueFiles = [
                  "$values/k8s-manifests/monitoring/prometheus-grafana.yaml",
                  "$secrets/monitoring/prometheus-grafana-secret.yaml",
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
            namespace = "monitoring"
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
            syncOptions = [
              "CreateNamespace=true",
              "ServerSideApply=true",
              "argocd.argoproj.io/sync-wave=0"
            ]
          }
        }
      }
    })
  ]

  depends_on = [
    kubernetes_manifest.argocd-github-access,
    kubernetes_namespace.monitoring,
    kubernetes_manifest.local_path_provisioner,
  ]
}

resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.2"
  namespace  = "argocd"

  atomic            = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    yamlencode({
      applications = {
        loki = {
          namespace = "argocd"
          project   = "default"
          sources = [
            {
              chart          = "loki"
              repoURL        = "https://grafana.github.io/helm-charts"
              targetRevision = "6.46.0"
              helm = {
                valueFiles = [
                  "$values/k8s-manifests/monitoring/loki.yaml"
                ]
              }
            },
            {
              repoURL        = "https://github.com/earseo/infra.git"
              targetRevision = "develop"
              ref            = "values"
            },
          ]
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "monitoring"
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
            syncOptions = [
              "CreateNamespace=true",
              "ServerSideApply=true",
              "argocd.argoproj.io/sync-wave=0"
            ]
          }
        }
      }
    })
  ]

  depends_on = [
    kubernetes_manifest.argocd-github-access,
    kubernetes_namespace.monitoring,
    kubernetes_manifest.local_path_provisioner,
  ]
}

resource "helm_release" "tempo" {
  name       = "tempo"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.2"
  namespace  = "argocd"

  atomic            = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    yamlencode({
      applications = {
        tempo = {
          namespace = "argocd"
          project   = "default"
          sources = [
            {
              chart          = "tempo"
              repoURL        = "https://grafana.github.io/helm-charts"
              targetRevision = "1.24.0"
              helm = {
                valueFiles = [
                  "$values/k8s-manifests/monitoring/tempo.yaml"
                ]
              }
            },
            {
              repoURL        = "https://github.com/earseo/infra.git"
              targetRevision = "develop"
              ref            = "values"
            },
          ]
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "monitoring"
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
            syncOptions = [
              "CreateNamespace=true",
              "ServerSideApply=true",
              "argocd.argoproj.io/sync-wave=0"
            ]
          }
        }
      }
    })
  ]

  depends_on = [
    kubernetes_manifest.argocd-github-access,
    kubernetes_namespace.monitoring,
    kubernetes_manifest.local_path_provisioner,
  ]
}

resource "helm_release" "otel-collector" {
  name       = "otel-collector"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.2"
  namespace  = "argocd"

  atomic            = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    yamlencode({
      applications = {
        otel-collector = {
          namespace = "argocd"
          project   = "default"
          sources = [
            {
              chart          = "opentelemetry-collector"
              repoURL        = "https://open-telemetry.github.io/opentelemetry-helm-charts"
              targetRevision = "0.139.0"
              helm = {
                valueFiles = [
                  "$values/k8s-manifests/monitoring/otel-collector.yaml"
                ]
              }
            },
            {
              repoURL        = "https://github.com/earseo/infra.git"
              targetRevision = "develop"
              ref            = "values"
            },
          ]
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "monitoring"
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
            syncOptions = [
              "CreateNamespace=true",
              "ServerSideApply=true",
              "argocd.argoproj.io/sync-wave=0"
            ]
          }
        }
      }
    })
  ]

  depends_on = [
    kubernetes_manifest.argocd-github-access,
    kubernetes_namespace.monitoring,
    kubernetes_manifest.local_path_provisioner,
  ]
}
