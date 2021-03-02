variable "bucket" {}
variable "image" {}
variable "image_file" {}
variable "image_name" {}
variable "image_family" { default = "openbsd-amd64-68" }
variable "project_id" {}
variable "region" {}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.58.0"
    }
  }
}

resource "google_storage_bucket" "lappland-openbsd-images" {
  name                        = var.bucket
  location                    = "EUROPE-WEST2"
  project                     = var.project_id
  storage_class               = "STANDARD"
  requester_pays              = true
  uniform_bucket_level_access = true
  force_destroy               = true
  lifecycle_rule {
    condition {
      age = 60
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket_object" "lappand-vpn-image" {
  name   = var.image_file
  source = var.image
  bucket = var.bucket
}

# resource "google_compute_image" "lappland_vpn_image" {
#   name = var.image_name
#   raw_disk {
#     source = "gs://${var.bucket}/${var.image_file}"
#     # sha1 = "003b5dca54c0931480a5e055659140b94cf87d76" hash bedfore extracting
#   }
#   family  = var.image_family
#   project = var.project_id
# }

output "image_hash" {
  value = google_storage_bucket_object.lappand-vpn-image.md5hash
}
