resource "google_compute_network" "vpc_network" {
  name = var.network_name
}

resource "google_compute_subnetwork" "vpc_subnet" {
  name          = var.subnet_name
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-only"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-server"]
}
