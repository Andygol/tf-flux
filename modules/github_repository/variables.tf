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
  default     = "flux-gitops"
  description = "The name of the repository."
}

variable "repository_visibility" {
  type        = string
  default     = "private"
  description = "The visibility of the repository."
}

variable "branch" {
  type        = string
  default     = "main"
  description = "The name of the branch of the repository."
}

variable "public_key_openssh" {
  type        = string
  description = "The public key to add to the repository."
}

variable "public_key_openssh_title" {
  type        = string
  description = "The title of the public key."
}
