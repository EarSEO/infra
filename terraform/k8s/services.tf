resource "kubernetes_namespace" "backend" {
  metadata {
    annotations = {
      name = "backend"
    }

    labels = {
      "argocd.argoproj.io/managed-by" = "argocd",
    }

    name = "backend"
  }
}

locals {
  backend_apps = {
    "backend-core" = {
      repoURL         = "https://earseo.github.io/infra-helm-pkg",
      sderviceRepoURL = "https://github.com/earseo/backend-core.git",
      chart           = "spring",
      targetRevision  = var.backend_core_version,
    },
    "backend-gateway" = {
      repoURL         = "https://earseo.github.io/infra-helm-pkg",
      sderviceRepoURL = "https://github.com/earseo/backend-gateway.git",
      chart           = "spring",
      targetRevision  = var.backend_gateway_version,
    },
    "backend-member" = {
      repoURL         = "https://earseo.github.io/infra-helm-pkg",
      sderviceRepoURL = "https://github.com/earseo/backend-member.git",
      chart           = "spring",
      targetRevision  = var.backend_member_version,
    },
    "backend-route" = {
      repoURL         = "https://earseo.github.io/infra-helm-pkg",
      sderviceRepoURL = "https://github.com/earseo/backend-route.git",
      chart           = "spring",
      targetRevision  = var.backend_route_version,
    },
    "backend-sight" = {
      repoURL         = "https://earseo.github.io/infra-helm-pkg",
      sderviceRepoURL = "https://github.com/earseo/backend-sight.git",
      chart           = "spring",
      targetRevision  = var.backend_sight_version,
    },
    "backend-story" = {
      repoURL         = "https://earseo.github.io/infra-helm-pkg",
      sderviceRepoURL = "https://github.com/earseo/backend-story.git",
      chart           = "spring",
      targetRevision  = var.backend_story_version,
    },
  }

  backend_applications = {
    for app_name, app_config in local.backend_apps : app_name => {
      namespace = "argocd"
      project   = "default"
      sources = [
        {
          chart          = app_config.chart
          repoURL        = app_config.repoURL
          targetRevision = app_config.targetRevision
          helm = {
            valueFiles = [
              "$service/k8s/helm-value.yaml",
              "$values/k8s-manifests/services/${app_name}.yaml",
              "$secrets/k8s-secret-manifests/services/${app_name}.yaml"
            ]
          }
        },
        {
          repoURL        = app_config.sderviceRepoURL
          targetRevision = "develop"
          ref            = "service"
        },
        {
          repoURL        = "https://github.com/earseo/infra.git"
          targetRevision = "develop"
          ref            = "values"
        },
        {
          repoURL        = "https://github.com/earseo/infra-secret-manifests.git"
          targetRevision = "main"
          ref            = "secrets"
        },
      ]
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "backend"
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
}

resource "helm_release" "backend_applications" {
  name       = "backend-applications"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.2"
  namespace  = "argocd"

  values = [
    yamlencode({
      applications = local.backend_applications
    })
  ]

  depends_on = [
    kubernetes_manifest.argocd-github-access,
    kubernetes_namespace.backend,
  ]
}
