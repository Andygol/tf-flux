terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.10.0"
    }
  }
}

provider "google" {
  project = var.google_project
  region  = var.google_region
  zone    = var.google_zone
}

resource "google_container_cluster" "this" {
  name     = var.cluster_name
  location = var.google_zone

  deletion_protection = false

  remove_default_node_pool = true

  #   initial_node_count = var.cluster_node_count
  initial_node_count = 1

  workload_identity_config {
    workload_pool = "${var.google_project}.svc.id.goog"
  }

  node_config {
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}

resource "google_container_node_pool" "this" {
  name       = var.cluster_pool_name
  project    = google_container_cluster.this.project
  cluster    = google_container_cluster.this.name
  location   = google_container_cluster.this.location
  node_count = var.cluster_node_count

  node_config {
    machine_type = var.cluster_node_machine_type
  }
}

module "gke_auth" {
  depends_on = [
    google_container_cluster.this
  ]
  source       = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  version      = ">= 29.0.0"
  cluster_name = google_container_cluster.this.name
  location     = google_container_cluster.this.location
  project_id   = var.google_project
}

resource "local_file" "kubeconfig" {
  content         = module.gke_auth.kubeconfig_raw
  filename        = "${path.module}/kubeconfig"
  file_permission = "0400"
}
