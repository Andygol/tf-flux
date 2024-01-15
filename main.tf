module "tls_private_key" {
  source    = "./modules/tls_private_key"
  algorithm = "RSA"
}

module "github_repository" {
  source                   = "./modules/github_repository"
  github_owner             = var.github_owner
  github_token             = var.github_token
  repository_name          = var.repository_name
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "flux-gitops"
}

module "gke_cluster" {
  source             = "./modules/gke"
  google_project     = var.google_project
  google_region      = var.google_region
  google_zone        = var.google_zone
  cluster_node_count = var.google_cluster_node_count
}

module "flux_bootstrap" {
  source          = "./modules/flux_bootstrap"
  github_token    = var.github_token
  cluster_name    = module.gke_cluster.cluster.name
  kubeconfig_path = module.gke_cluster.kubeconfig
  git_url         = module.github_repository.values.url
  /*
  google_project = var.google_project
  google_zone    = var.google_zone
*/
}

module "gke_workload_identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  use_existing_k8s_sa = true
  annotate_k8s_sa     = true
  name                = "kustomize-controller"
  namespace           = "flux-system"
  project_id          = var.google_project
  location            = var.google_zone
  cluster_name        = module.gke_cluster.cluster.name
  roles               = ["roles/cloudkms.cryptoKeyEncrypterDecrypter"]

  module_depends_on = [
    module.flux_bootstrap
  ]
}

data "google_kms_key_ring" "key_ring" {
  name     = "sops-flux"
  location = "global"
  project  = var.google_project
}

import {
  to = google_kms_key_ring.key_ring
  id = "projects/${var.google_project}/locations/${data.google_kms_key_ring.key_ring.location}/keyRings/${data.google_kms_key_ring.key_ring.name}"
}

resource "google_kms_key_ring" "key_ring" {
  count    = data.google_kms_key_ring.key_ring.name != null ? 0 : 1
  name     = "sops-flux"
  location = "global"
  project  = var.google_project

  lifecycle {
    prevent_destroy = false
  }
}

module "google_kms" {
  source          = "terraform-google-modules/kms/google"
  version         = "2.2.3"
  keyring         = coalesce(data.google_kms_key_ring.key_ring.name, try(google_kms_key_ring.key_ring[0].name, null))
  keys            = ["sops-key-flux"]
  location        = "global"
  project_id      = var.google_project
  prevent_destroy = false
}

resource "null_resource" "git_commit" {
  depends_on = [
    module.flux_bootstrap
  ]

  provisioner "local-exec" {
    command = <<EOF
      if [ -d ${var.repository_name} ]; then
        rm -rf ${var.repository_name}
      fi
      git clone ${module.github_repository.values.http_clone_url}
      # git clone https://github.com/Andygol/${var.repository_name}.git
      mkdir -p ${var.repository_name}/clusters/${module.gke_cluster.cluster.name}/kubot
      cd ${var.repository_name}/clusters/${module.gke_cluster.cluster.name}/kubot
      cat <<EOHELMRELEASE > kubot-helm-release.yaml
apiVersion: helm.toolkit.fluxcd.io/v2beta2
kind: HelmRelease
metadata:
  name: kubot
  namespace: kubot
spec:
  chart:
    spec:
      chart: ./helm
      reconcileStrategy: ChartVersion
      sourceRef:
        kind: GitRepository
        name: kubot
  interval: 1m0s
EOHELMRELEASE
      cat <<EOGITREPO > kubot-git-repository.yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: kubot
  namespace: kubot
spec:
  interval: 1m0s
  ref:
    branch: main
  url: https://github.com/Andygol/kubot.git
EOGITREPO
      cat <<EONAMESPACE > kubot-namespaces.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: kubot
EONAMESPACE
      cd ../flux-system
      cat <<EOSAPATCH > sa-patch.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: sa-patch
  namespace: flux-system
  annotations:
    iam.gke.io/gcp-service-account: kustomize-controller@k8s-ah.iam.gserviceaccount.com
EOSAPATCH
      cat <<EOSOPSPATCH > sops-patch.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: flux-system
  namespace: flux-system
spec:
  decryption:
    provider: sops
  interval: 10m0s
  path: ./clusters/main
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
EOSOPSPATCH
      cat <<EOKUSTOMIZATION > kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- gotk-components.yaml
- gotk-sync.yaml
patches:
  - path: sops-patch.yaml
    target:
      kind: Kustomization
  - path: sa-patch.yaml
    target:
      kind: ServiceAccount
      name: kustomize-controller
EOKUSTOMIZATION
      git add --all
      git commit -m "Add Kubernetes manifests and patches"
      git push origin main
    EOF
  }
}

resource "null_resource" "cluster_credentials" {
  depends_on = [
    module.gke_cluster,
    module.flux_bootstrap
  ]

  provisioner "local-exec" {
    command = <<EOF
      ${module.gke_cluster.cluster.gke_get_credentials_command}
    EOF
  }
}

resource "null_resource" "gitops_destroy" {
      depends_on = [
      null_resource.git_commit,
      module.flux_bootstrap
    ]
    
  triggers = {
    repo_name = module.github_repository.values.name
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
      if [ -d ${self.triggers.repo_name} ]; then
        rm -rf ${self.triggers.repo_name}
      fi
    EOF
  }
}