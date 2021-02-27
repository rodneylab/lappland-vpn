terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.57.0"
    }
  }
}

data "google_compute_regions" "available" {}

output "regions" {
  value = data.google_compute_regions.available.names
}
