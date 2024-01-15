terraform {
  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = "~> 1.2.2"
    }
  }
}

provider "flux" {
  kubernetes = {
    config_path = var.kubeconfig_path
    /*
    exec = {
      command = "gcloud"
      args = [
        "container",
        "clusters",
        "get-credentials",
        var.cluster_name,
        "--zone",
        var.google_zone,
        "--project",
        var.google_project
      ]
      api_version = "client.authentication.k8s.io/v1beta1"
    }
*/
  }
  git = {
    url = var.git_url
    http = {
      username = "git"
      password = var.github_token
    }
  }
}

resource "flux_bootstrap_git" "this" {
  path                   = "clusters/${var.cluster_name}"
  kustomization_override = file("${path.module}/kustomization.yaml")
}
