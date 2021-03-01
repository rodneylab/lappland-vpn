variable "bucket" {}
variable "image" {}
variable "image_name" {}
variable "image_family" { default = "openbsd-amd64-68" }
variable "lappland_id" { default = "lappland" }
variable "project_id" {}
variable "region" {}
variable "server_name" {}
variable "ssh_key" {}
variable "ssh_port" {}
variable "wg_port" {}
variable "firewall_select_source" {}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.57.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
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
  name   = var.image_name
  source = var.image
  bucket = var.bucket
}

# data "google_compute_image" "lappland_vpn_image" {
#   family  = var.image_family
#   project = var.project_id
# }

resource "google_compute_image" "lappland_vpn_image" {
  # name        = "openbsd-amd64-68-201107"
  # source_disk = "gs://${var.bucket}/${var.image_name}"
  raw_disk {
    source = "gs://${var.bucket}/${var.image_name}"
    # sha1 = "003b5dca54c0931480a5e055659140b94cf87d76" hash bedfore extracting
  }
  family  = var.image_family
  project = var.project_id
}

# data "google_compute_regions" "available" {
# }

# resource "google_compute_subnetwork" "cluster" {
#   count         = length(data.google_compute_regions.available.names)
#   name          = "my-network"
#   ip_cidr_range = "10.36.${count.index}.0/24"
#   network       = "my-network"
#   region        = data.google_compute_regions.available.names[count.index]
# }

# provider "google" {
#   region = data.google_compute_regions.available.names[count.index]
# }

resource "google_compute_network" "vpc_network" {
  name         = "lappland"
  routing_mode = "REGIONAL"
}

resource "google_compute_firewall" "default" {
  name          = "lapplandvpn"
  network       = "lappland"
  direction     = "INGRESS"
  source_ranges = split(",", var.firewall_select_source)
  allow {
    protocol = "tcp"
    ports    = [var.ssh_port]
  }
  allow {
    protocol = "udp"
    ports    = [var.wg_port]
  }
  target_tags = ["lappland-vpn"]
}

resource "google_compute_address" "static" {
  name = var.server_name
}

# data "google_compute_image" "openbsd_image" {
#   family = var.image_family
# }


resource "google_project" "project" {
  name       = "lappland-vpn"
  project_id = var.project_id
}

resource "google_project_service" "service" {
  for_each = toset([
    "compute.googleapis.com"
  ])

  service = each.key

  project            = var.project_id
  disable_on_destroy = false
}

data "google_compute_zones" "available" {
  project = var.project_id
}

resource "random_shuffle" "zones" {
  input        = data.google_compute_zones.available.names
  result_count = 1
}

resource "google_compute_instance" "lappland_vpn" {
  name         = var.server_name
  zone         = random_shuffle.zones.result[0]
  machine_type = "f1-micro"
  tags         = ["lappland-vpn"]

  boot_disk {
    initialize_params {
      image = google_compute_image.lappland_vpn_image.self_link
    }
  }

  metadata = {
    ssh-keys    = var.ssh_key
    lappland-id = var.lappland_id
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      nat_ip = google_compute_address.static.address
      # type         = "ONE_TO_ONE_NAT"
      network_tier = "PREMIUM"
    }
  }
  depends_on = [google_project_service.service]
}

output "instance_id" {
  value = google_compute_instance.lappland_vpn.self_link
}

output "image_hash" {
  value = google_storage_bucket_object.lappand-vpn-image.md5hash
}
