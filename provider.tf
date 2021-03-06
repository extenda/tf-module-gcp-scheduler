terraform {
  # The configuration for this backend will be filled in by Terragrunt
  required_version = ">= 0.12.18"
}

provider "google" {
  region = var.region
}

provider "google-beta" {
  region = var.region
}
