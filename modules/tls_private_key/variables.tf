variable "algorithm" {
  type        = string
  default     = "ECDSA"
  description = "The algorithm to use for key generation. Valid values are RSA, ECDSA, and Ed25519."
}

variable "ecdsa_curve" {
  type        = string
  default     = "P256"
  description = "The ECDSA curve to use for key generation. Valid values are P224, P256, P384, and P521."
}
