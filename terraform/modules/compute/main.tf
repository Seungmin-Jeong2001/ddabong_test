terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

resource "google_compute_instance" "web_server" {
  name         = "bucheong-cat-server"
  machine_type = "e2-small"
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network    = var.network_id
    subnetwork = var.subnet_id
    access_config {
      // Ephemeral public IP
    }
  }

  tags = ["ssh-server"]

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_pub_key}"
  }
}
