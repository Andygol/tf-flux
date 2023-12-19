terraform {
  backend "gcs" {
    bucket = "tf-flux"
    prefix = "terraform/state"
  }
}
