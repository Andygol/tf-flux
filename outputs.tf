output "repository" {
  value = module.github_repository.values
}

output "kubeconfig" {
  value       = module.gke_cluster.kubeconfig
  description = "The kubeconfig file for the cluster."
}

output "cluster" {
  value       = module.gke_cluster.cluster
  description = "Information about the cluster."
}

output "gke_get_credentials_command" {
  value       = module.gke_cluster.cluster.gke_get_credentials_command
  description = "Run this command to configure kubectl to connect to the cluster."
}