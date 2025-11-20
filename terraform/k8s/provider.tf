terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.0"
    }
  }
}

provider "kubernetes" {
  config_path = "../../kubespray/admin.conf"
}

provider "helm" {
  kubernetes = {
    config_path = "../../kubespray/admin.conf"
  }
}
