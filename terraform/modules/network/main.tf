# 1. VPC 네트워크 생성
resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

# 2. 서브넷 생성
resource "google_compute_subnetwork" "vpc_subnet" {
  name          = var.subnet_name
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc_network.id
}

# 3. SSH 방화벽
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.network_name}-allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-server"]
}

# 4. 서비스 방화벽 (앱, 프로메테우스, 얼럿매니저)
resource "google_compute_firewall" "allow_services" {
  name    = "${var.network_name}-allow-services"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "9090", "9093"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-server"]
}