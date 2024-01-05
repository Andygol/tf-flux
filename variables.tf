variable "github_owner" {
  type        = string
  description = "The owner of the repository."
}

variable "github_token" {
  type        = string
  description = "The GitHub token to use for authentication."
}

variable "repository_name" {
  type        = string
  description = "The name of the repository."
}

variable "google_project" {
  type        = string
  description = "The Google Cloud project ID."
}

variable "google_region" {
  type        = string
  default     = "us-central1"
  description = "The Google Cloud region to deploy to."
}

variable "google_zone" {
  type        = string
  default     = "us-central1-c"
  description = "The Google Cloud zone to deploy to."

}

variable "google_cluster_node_count" {
  type        = number
  default     = 3
  description = "The number of nodes in the cluster."
}
