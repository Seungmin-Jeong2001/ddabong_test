resource "google_compute_network" "vpc_network" {
  name = "cat-monitor-network"
}

resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "cat-monitor-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_instance" "web_server" {
  name         = "bucheong-cat-server"
  machine_type = "e2-micro"
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.vpc_subnet.id

    access_config {
      // Ephemeral public IP
    }
  }

  tags = ["http-server"]

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_pub_key}"
  }
}

resource "cloudflare_record" "domain_a" {
  zone_id = var.cloudflare_zone_id
  name    = "bucheongoyangijanggun.com"
  content = google_compute_instance.web_server.network_interface.0.access_config.0.nat_ip
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "www" {
  zone_id = var.cloudflare_zone_id
  name    = "www"
  content = "bucheongoyangijanggun.com"
  type    = "CNAME"
  proxied = true
}
