output "kubeconfig" {
  value       = local_file.kubeconfig.filename
  description = "The path to the kubeconfig file."
}

output "cluster" {
  value = {
    name    = google_container_cluster.this.name
    zone    = google_container_cluster.this.location
    project = google_container_cluster.this.project

    gke_get_credentials_command = "gcloud container clusters get-credentials ${google_container_cluster.this.name} --zone ${google_container_cluster.this.location} --project ${google_container_cluster.this.project}"
  }
  description = "The GKE cluster details"
}
