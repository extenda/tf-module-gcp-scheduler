terraform {
  # The configuration for this backend will be filled in by Terragrunt
  required_version = ">= 1.4.6"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 4.62.0"
    }
    google-beta = {
      source = "hashicorp/google-beta"
      version = "~> 4.62.0"
    }
  }
}

provider "google" {
  region = var.region
}

provider "google-beta" {
  region = var.region
}
