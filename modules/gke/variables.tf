variable "google_project" {
  type        = string
  description = "The Google Cloud project to deploy to."
}

variable "google_region" {
  type        = string
  default     = "us-central1-c"
  description = "The Google Cloud region to deploy to."
}

variable "google_zone" {
  type        = string
  default     = "us-central1-c"
  description = "The Google Cloud zone to deploy to."
}

variable "cluster_name" {
  type        = string
  default     = "main"
  description = "The name of the cluster."
}

variable "cluster_pool_name" {
  type        = string
  default     = "main"
  description = "The name of the cluster pool."
}

variable "cluster_node_count" {
  type        = number
  default     = 3
  description = "The number of nodes in the cluster."
}

variable "cluster_node_machine_type" {
  type    = string
  default = "g1-small"
  #   default     = "n1-standard-2"
  #   default     = "e2-standard-2"
  #   default     = "e2-micro"
  description = "The machine type of the nodes in the cluster."
}
