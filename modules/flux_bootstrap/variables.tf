variable "git_url" {
  type        = string
  description = "The URL of the Git repository."
}

variable "github_token" {
  type        = string
  description = "The GitHub token to use for authentication."
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster."
}

variable "kubeconfig_path" {
  type        = string
  default     = "~/.kube/config"
  description = "The path to the kubeconfig file."
}

/*
variable "google_zone" {
  type = string
  description = "The zone of the cluster."
}
variable "google_project" {
  type = string
  description = "The project."
}
*/