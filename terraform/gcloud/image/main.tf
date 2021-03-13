variable "bucket" {
  description = "The name of the bucket to create."
  type        = string
}
variable "image" {}
variable "image_file" {}
variable "image_name" {}
variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}
variable "region" {}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.58.0"
    }
  }
  required_version = ">= 0.12"
}

resource "google_project_service" "service" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com"
  ])

  service = each.key

  project            = var.project_id
  disable_on_destroy = false
}

resource "google_storage_bucket" "lappland-openbsd-images" {
  name          = var.bucket
  project       = var.project_id
  location      = "EUROPE-WEST2"
  storage_class = "STANDARD"
  # requester_pays              = true
  uniform_bucket_level_access = true
  force_destroy               = true
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age        = 60
      with_state = "ANY"
    }
  }

  # iam_members = [{
  #   role = "roles/storage.viewer"
  #   # member = "user:example-user@example.com"
  #   member = var.service_account
  # }]
}

resource "google_storage_bucket_object" "lappand-vpn-image" {
  bucket = var.bucket
  name   = var.image_file
  source = var.image
}

output "image_hash" {
  value = google_storage_bucket_object.lappand-vpn-image.md5hash
}
